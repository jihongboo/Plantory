import SwiftUI
import UIKit

struct ImageCropperItem: Identifiable {
    let id = UUID()
    let image: PlatformImage
}

private struct ImageCropperPage: View {
    let sourceImage: PlatformImage
    let onCancel: () -> Void
    let onCrop: (PlatformImage) -> Void

    @State private var cropRect: CGRect = .zero
    @State private var dragStartRect: CGRect = .zero
    @State private var activeImageFrame: CGRect = .zero
    @State private var didInitializeCrop = false
    @State private var didUserAdjustCrop = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                GeometryReader { proxy in
                    let imageFrame = sourceImage.size.aspectFitRect(in: CGRect(origin: .zero, size: proxy.size))

                    ZStack {
                        Color.white

                        Image(uiImage: sourceImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageFrame.width, height: imageFrame.height)
                            .position(x: imageFrame.midX, y: imageFrame.midY)

                        cropOverlay(in: imageFrame)

                        Color.clear
                            .onAppear {
                                updateImageFrame(imageFrame)
                            }
                            .onChange(of: proxy.size) {
                                updateImageFrame(imageFrame)
                            }
                            .allowsHitTesting(false)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 20)

                Button("Reset", systemImage: "arrow.counterclockwise") {
                    cropRect = activeImageFrame == .zero ? .zero : defaultCropRect(in: activeImageFrame)
                    didUserAdjustCrop = false
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 20)
            .background(Color.white)
            .navigationTitle("Crop Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Use Photo") {
                        guard cropRect.width > 1,
                              cropRect.height > 1,
                              activeImageFrame.width > 1,
                              activeImageFrame.height > 1 else { return }
                        let croppedImage = sourceImage.croppedImage(
                            cropRect: cropRect,
                            imageFrame: activeImageFrame
                        )
                        onCrop(croppedImage)
                    }
                    .bold()
                }
            }
        }
    }

    @ViewBuilder
    private func cropOverlay(in imageFrame: CGRect) -> some View {
        let activeRect = cropRect == .zero ? defaultCropRect(in: imageFrame) : cropRect

        ZStack {
            dimmingLayer(cropRect: activeRect, imageFrame: imageFrame)

            Rectangle()
                .stroke(.white, lineWidth: 2)
                .shadow(color: .black.opacity(0.35), radius: 6)
                .frame(width: activeRect.width, height: activeRect.height)
                .position(x: activeRect.midX, y: activeRect.midY)
                .contentShape(Rectangle())
                .gesture(moveGesture(in: imageFrame))

            ForEach(CropHandle.allCases) { handle in
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.001))
                        .frame(width: Self.cropHandleHitLength, height: Self.cropHandleHitLength)

                    Circle()
                        .fill(.white)
                        .frame(width: Self.cropHandleVisibleLength, height: Self.cropHandleVisibleLength)
                        .overlay {
                            Circle()
                                .stroke(.green, lineWidth: 2)
                        }
                }
                    .contentShape(Circle())
                    .position(handle.point(in: activeRect))
                    .highPriorityGesture(resizeGesture(handle: handle, in: imageFrame))
                    .accessibilityElement()
                    .accessibilityLabel(handle.accessibilityLabel)
                    .accessibilityHint("Drag to resize the crop box.")
            }
        }
    }

    private static let cropHandleVisibleLength: CGFloat = 32
    private static let cropHandleHitLength: CGFloat = 64

    private func dimmingLayer(cropRect: CGRect, imageFrame: CGRect) -> some View {
        Path { path in
            path.addRect(imageFrame)
            path.addRect(cropRect)
        }
        .fill(.black.opacity(0.42), style: FillStyle(eoFill: true))
    }

    private func moveGesture(in imageFrame: CGRect) -> some Gesture {
        DragGesture()
            .onChanged { value in
                didUserAdjustCrop = true
                if dragStartRect == .zero {
                    dragStartRect = cropRect
                }

                let proposedRect = dragStartRect.offsetBy(
                    dx: value.translation.width,
                    dy: value.translation.height
                )
                cropRect = clamped(proposedRect, in: imageFrame)
            }
            .onEnded { _ in
                dragStartRect = .zero
            }
    }

    private func resizeGesture(handle: CropHandle, in imageFrame: CGRect) -> some Gesture {
        DragGesture()
            .onChanged { value in
                didUserAdjustCrop = true
                if dragStartRect == .zero {
                    dragStartRect = cropRect
                }

                cropRect = resized(
                    dragStartRect,
                    handle: handle,
                    translation: value.translation,
                    in: imageFrame
                )
            }
            .onEnded { _ in
                dragStartRect = .zero
            }
    }

    private func defaultCropRect(in imageFrame: CGRect) -> CGRect {
        let width = imageFrame.width * 0.9
        let height = imageFrame.height * 0.9

        return CGRect(
            x: imageFrame.midX - width / 2,
            y: imageFrame.midY - height / 2,
            width: width,
            height: height
        )
    }

    private func updateImageFrame(_ imageFrame: CGRect) {
        guard imageFrame.width > 1, imageFrame.height > 1 else { return }

        activeImageFrame = imageFrame
        if !didInitializeCrop || !didUserAdjustCrop {
            cropRect = defaultCropRect(in: imageFrame)
            didInitializeCrop = true
        } else {
            cropRect = clamped(cropRect, in: imageFrame)
        }
    }

    private func clamped(_ rect: CGRect, in imageFrame: CGRect) -> CGRect {
        let width = min(max(rect.width, Self.minimumCropLength), imageFrame.width)
        let height = min(max(rect.height, Self.minimumCropLength), imageFrame.height)
        let minX = min(max(rect.minX, imageFrame.minX), imageFrame.maxX - width)
        let minY = min(max(rect.minY, imageFrame.minY), imageFrame.maxY - height)

        return CGRect(x: minX, y: minY, width: width, height: height)
    }

    private func resized(
        _ rect: CGRect,
        handle: CropHandle,
        translation: CGSize,
        in imageFrame: CGRect
    ) -> CGRect {
        var minX = rect.minX
        var minY = rect.minY
        var maxX = rect.maxX
        var maxY = rect.maxY

        switch handle {
        case .topLeading:
            minX = min(max(rect.minX + translation.width, imageFrame.minX), rect.maxX - Self.minimumCropLength)
            minY = min(max(rect.minY + translation.height, imageFrame.minY), rect.maxY - Self.minimumCropLength)
        case .topTrailing:
            maxX = max(min(rect.maxX + translation.width, imageFrame.maxX), rect.minX + Self.minimumCropLength)
            minY = min(max(rect.minY + translation.height, imageFrame.minY), rect.maxY - Self.minimumCropLength)
        case .bottomLeading:
            minX = min(max(rect.minX + translation.width, imageFrame.minX), rect.maxX - Self.minimumCropLength)
            maxY = max(min(rect.maxY + translation.height, imageFrame.maxY), rect.minY + Self.minimumCropLength)
        case .bottomTrailing:
            maxX = max(min(rect.maxX + translation.width, imageFrame.maxX), rect.minX + Self.minimumCropLength)
            maxY = max(min(rect.maxY + translation.height, imageFrame.maxY), rect.minY + Self.minimumCropLength)
        }

        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    private static let minimumCropLength: CGFloat = 96
}

private struct ImageCropperModifier: ViewModifier {
    @Binding var item: ImageCropperItem?
    let onCrop: (PlatformImage) -> Void

    func body(content: Content) -> some View {
        content
            .fullScreenCover(item: $item) { item in
                ImageCropperPage(
                    sourceImage: item.image.normalizedForProcessing(),
                    onCancel: {
                        self.item = nil
                    },
                    onCrop: { image in
                        self.item = nil
                        onCrop(image)
                    }
                )
            }
    }
}

private extension PlatformImage {
    func croppedImage(
        cropRect: CGRect,
        imageFrame: CGRect
    ) -> PlatformImage {
        let outputSize: CGSize = {
            let maxDimension: CGFloat = 1400
            let ratio = cropRect.width / cropRect.height
            if ratio >= 1 {
                return CGSize(width: maxDimension, height: maxDimension / ratio)
            }
            return CGSize(width: maxDimension * ratio, height: maxDimension)
        }()

        let imageFrame = CGRect(
            x: imageFrame.minX - cropRect.minX,
            y: imageFrame.minY - cropRect.minY,
            width: imageFrame.width,
            height: imageFrame.height
        )

        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1
        rendererFormat.opaque = true

        return UIGraphicsImageRenderer(size: outputSize, format: rendererFormat).image { context in
            context.cgContext.setFillColor(UIColor.white.cgColor)
            context.cgContext.fill(CGRect(origin: .zero, size: outputSize))

            context.cgContext.scaleBy(
                x: outputSize.width / cropRect.width,
                y: outputSize.height / cropRect.height
            )
            draw(in: imageFrame)
        }
    }
}

extension View {
    func imageCropper(
        item: Binding<ImageCropperItem?>,
        onCrop: @escaping (PlatformImage) -> Void
    ) -> some View {
        modifier(ImageCropperModifier(item: item, onCrop: onCrop))
    }
}

private extension CGSize {
    func aspectFitRect(in rect: CGRect) -> CGRect {
        let scale = min(rect.width / width, rect.height / height)
        let fittedSize = CGSize(width: width * scale, height: height * scale)

        return CGRect(
            x: rect.midX - fittedSize.width / 2,
            y: rect.midY - fittedSize.height / 2,
            width: fittedSize.width,
            height: fittedSize.height
        )
    }
}

private enum CropHandle: CaseIterable, Identifiable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var id: Self { self }

    var accessibilityLabel: Text {
        switch self {
        case .topLeading:
            Text("Top left crop handle")
        case .topTrailing:
            Text("Top right crop handle")
        case .bottomLeading:
            Text("Bottom left crop handle")
        case .bottomTrailing:
            Text("Bottom right crop handle")
        }
    }

    func point(in rect: CGRect) -> CGPoint {
        switch self {
        case .topLeading:
            CGPoint(x: rect.minX, y: rect.minY)
        case .topTrailing:
            CGPoint(x: rect.maxX, y: rect.minY)
        case .bottomLeading:
            CGPoint(x: rect.minX, y: rect.maxY)
        case .bottomTrailing:
            CGPoint(x: rect.maxX, y: rect.maxY)
        }
    }
}

#Preview {
    NavigationStack {
        if let imageData = PlatformImageData.named("Monstera deliciosa"),
           let image = PlatformImage(data: imageData) {
            ImageCropperPage(
                sourceImage: image,
                onCancel: {},
                onCrop: { _ in }
            )
        }
    }
}
