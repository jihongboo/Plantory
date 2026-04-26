import SwiftUI

struct PlantImageImportMenu<LabelContent: View>: View {
    let purpose: PlantPhotoImportPurpose
    let onImageDataPrepared: (Data) -> Void
    @ViewBuilder let label: (_ isPreparingImage: Bool) -> LabelContent

    @State private var showCameraPicker = false
    @State private var pendingSourceImage: PlatformImage?
    @State private var pendingCropItem: ImageCropperItem?
    @State private var isPreparingImage = false

    init(
        purpose: PlantPhotoImportPurpose = .addPlant,
        onImageDataPrepared: @escaping (Data) -> Void,
        @ViewBuilder label: @escaping (_ isPreparingImage: Bool) -> LabelContent
    ) {
        self.purpose = purpose
        self.onImageDataPrepared = onImageDataPrepared
        self.label = label
    }

    var body: some View {
        Button {
            showCameraPicker = true
        } label: {
            label(isPreparingImage)
        }
        .disabled(isPreparingImage)
        .cameraPicker(
            purpose: purpose,
            isPresented: $showCameraPicker,
            image: $pendingSourceImage
        )
        .onChange(of: pendingSourceImage) {
            guard let pendingSourceImage else { return }
            pendingCropItem = ImageCropperItem(image: pendingSourceImage)
            self.pendingSourceImage = nil
        }
        .imageCropper(item: $pendingCropItem) { croppedImage in
            Task {
                await prepareImage(from: croppedImage)
            }
        }
    }
}

private extension PlantImageImportMenu {
    static var visionWorkingMaxPixelDimension: CGFloat { 1200 }
    static var foregroundMaxPixelDimension: CGFloat { 1400 }
    static var foregroundCompressionRatio: CGFloat { 0.9 }
    static var fallbackJPEGQuality: CGFloat { 0.78 }

    func prepareImage(from sourceImage: PlatformImage?) async {
        guard let sourceImage else { return }

        isPreparingImage = true
        defer { isPreparingImage = false }

        let normalizedImage = sourceImage.normalizedForProcessing()
        switch purpose {
        case .addPlant:
            await prepareAddPlantImage(from: normalizedImage)
        case .diagnosis:
            prepareDiagnosisImage(from: normalizedImage)
        }

        pendingSourceImage = nil
    }

    func prepareAddPlantImage(from normalizedImage: PlatformImage) async {
        let visionWorkingImage = normalizedImage.resizedToFit(
            maxPixelDimension: Self.visionWorkingMaxPixelDimension
        )
        let fallbackData = ImageCompression.compressedJPEGData(
            from: normalizedImage,
            maxPixelDimension: Self.foregroundMaxPixelDimension,
            compressionQuality: Self.fallbackJPEGQuality
        )

        do {
            let isolatedData = try await PlantForegroundIsolation.isolatedPNGData(
                from: visionWorkingImage,
                maxPixelDimension: Self.foregroundMaxPixelDimension,
                compressionRatio: Self.foregroundCompressionRatio
            )
            onImageDataPrepared(isolatedData)
        } catch {
            guard let fallbackData else { return }
            onImageDataPrepared(fallbackData)
        }
    }

    func prepareDiagnosisImage(from normalizedImage: PlatformImage) {
        guard let imageData = ImageCompression.compressedJPEGData(
            from: normalizedImage,
            profile: ImageCompression.diagnosisUploadProfile
        ) else {
            return
        }
        onImageDataPrepared(imageData)
    }
}

#Preview {
    PlantImageImportMenu { _ in } label: { _ in
        SwiftUI.Label("Add Plant", systemImage: "plus")
    }
}

extension Data: @retroactive Identifiable {
    public var id: Int {
        hashValue
    }
}
