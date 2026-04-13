import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddPlantMenuView: View {
    @State private var showCameraPicker = false
    @State private var showPhotoPicker = false
    @State private var showFileImporter = false
    @State private var pendingSourceImage: PlatformImage?
    @State private var imageData: Data?
    @State private var isPreparingImage = false

    var body: some View {
        Menu {
            #if !os(macOS)
            Button { showCameraPicker = true } label: {
                Label("Camera", systemImage: "camera.fill")
            }
            #endif
            Button { showPhotoPicker = true } label: {
                Label("Photo Library", systemImage: "photo.stack")
            }
            #if os(macOS)
            Button { showFileImporter = true } label: {
                Label("Files", systemImage: "folder")
            }
            #endif
        }
        label: {
            if isPreparingImage {
                Label("Processing...", systemImage: "hourglass")
                    .symbolEffect(.rotate, options: .speed(0.5))
            } else {
                Label("Add Plant", systemImage: "plus")
            }
        }
        .compositingGroup()
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(isPreparingImage)
        .cameraPicker(isPresented: $showCameraPicker, image: $pendingSourceImage)
        .plantPhotoPicker(isPresented: $showPhotoPicker, image: $pendingSourceImage)
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false,
            onCompletion: handleImportedImage
        )
        .onChange(of: pendingSourceImage) {
            guard let pendingSourceImage else { return }
            Task {
                await prepareImage(from: pendingSourceImage)
            }
        }
        .sheet(item: $imageData) { imageData in
            AddPlantView(imageData: imageData)
        }
    }
}

#Preview {
    AddPlantMenuView()
}

extension Data: @retroactive Identifiable {
    public var id: Int {
        self.hashValue
    }
}

private extension AddPlantMenuView {
    static let visionWorkingMaxPixelDimension: CGFloat = 1200
    static let foregroundMaxPixelDimension: CGFloat = 1400
    static let foregroundCompressionRatio: CGFloat = 0.9
    static let fallbackJPEGQuality: CGFloat = 0.78

    func prepareImage(from sourceImage: PlatformImage?) async {
        guard let sourceImage else { return }

        isPreparingImage = true
        defer { isPreparingImage = false }

        let normalizedImage = sourceImage.normalizedForProcessing()
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
            imageData = isolatedData
        } catch {
            imageData = fallbackData
        }

        pendingSourceImage = nil
    }

    func handleImportedImage(_ result: Result<[URL], Error>) {
        guard case let .success(urls) = result,
              let url = urls.first else {
            return
        }

        let didAccessSecurityScope = url.startAccessingSecurityScopedResource()
        defer {
            if didAccessSecurityScope {
                url.stopAccessingSecurityScopedResource()
            }
        }

        guard let importedData = try? Data(contentsOf: url) else { return }
        pendingSourceImage = PlatformImage(data: importedData)
    }
}
