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
            PixelPage {
                VStack(spacing: 16) {
                    cropperNavigationBar

                    cropCanvas

                    cropHint
                }
            }
            .pixelBottomActionBar(spacing: 10) {
                Button("Reset", systemImage: "arrow.counterclockwise", action: resetCrop)
                    .buttonStyle(.pixelRoundedRectangle(fill: .pixelPaperShadow, foreground: .pixelInk, width: .expanded))

                Button("Use Photo", systemImage: "checkmark", action: performCrop)
                    .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            }
        }
    }

    private static let cropHandleVisibleLength: CGFloat = 32
    private static let cropHandleHitLength: CGFloat = 64

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

private struct GridPattern: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        var path = Path()
        let step: CGFloat = 16

        stride(from: rect.minX, through: rect.maxX, by: step).forEach { x in
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        stride(from: rect.minY, through: rect.maxY, by: step).forEach { y in
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        return path
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
        if let imageData = PlatformImageData.monstera,
           let image = PlatformImage(data: imageData) {
            ImageCropperPage(
                sourceImage: image,
                onCancel: {},
                onCrop: { _ in }
            )
        }
    }
}

private extension ImageCropperPage {
    var cropperNavigationBar: some View {
        HStack(spacing: 12) {
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle(fill: .pixelPaperShadow, foreground: .pixelInk, padding: 12))
            .accessibilityLabel("Cancel")

            VStack(alignment: .leading, spacing: -4) {
                Text("Crop Photo")
                    .font(.pixel(.title))
                    .foregroundStyle(.white)
                    .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)

                Text("Frame your plant")
                    .font(.pixel(.body))
                    .foregroundStyle(.pixelCream)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    var cropCanvas: some View {
        PixelRoundedRectangleCard(fill: .pixelPaper, padding: 8) {
            GeometryReader { proxy in
                let imageFrame = sourceImage.size.aspectFitRect(in: CGRect(origin: .zero, size: proxy.size))

                ZStack {
                    pixelCanvasBackground

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
                .clipShape(.rect(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.pixelInk.opacity(0.64), lineWidth: 3)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var cropHint: some View {
        Label("Drag the frame or pull the corner blocks.", systemImage: "crop")
            .font(.pixel(.callout))
            .foregroundStyle(.pixelCream)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    var pixelCanvasBackground: some View {
        ZStack {
            Color.pixelInk.opacity(0.9)

            Color.pixelLeafDark.opacity(0.28)

            GridPattern()
                .stroke(.pixelCream.opacity(0.08), lineWidth: 1)
        }
    }

    @ViewBuilder
    func cropOverlay(in imageFrame: CGRect) -> some View {
        let activeRect = cropRect == .zero ? defaultCropRect(in: imageFrame) : cropRect

        ZStack {
            dimmingLayer(cropRect: activeRect, imageFrame: imageFrame)

            cropFrame(activeRect)
                .position(x: activeRect.midX, y: activeRect.midY)
                .contentShape(Rectangle())
                .gesture(moveGesture(in: imageFrame))

            ForEach(CropHandle.allCases) { handle in
                cropHandle(for: handle, in: activeRect)
                    .position(handle.point(in: activeRect))
                    .highPriorityGesture(resizeGesture(handle: handle, in: imageFrame))
                    .accessibilityElement()
                    .accessibilityLabel(handle.accessibilityLabel)
                    .accessibilityHint("Drag to resize the crop box.")
            }
        }
    }

    func cropFrame(_ rect: CGRect) -> some View {
        Rectangle()
            .stroke(.pixelCream, lineWidth: 4)
            .overlay {
                Rectangle()
                    .stroke(.pixelLeaf, style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .padding(8)
            }
            .shadow(color: .pixelInk.opacity(0.75), radius: 0, x: 4, y: 4)
            .frame(width: rect.width, height: rect.height)
    }

    func cropHandle(for handle: CropHandle, in rect: CGRect) -> some View {
        ZStack {
            Rectangle()
                .fill(.white.opacity(0.001))
                .frame(width: Self.cropHandleHitLength, height: Self.cropHandleHitLength)

            PixelRectangleBackground(fill: .pixelCream)
                .frame(width: Self.cropHandleVisibleLength, height: Self.cropHandleVisibleLength)
                .overlay {
                    handleAccent(for: handle)
                        .stroke(.pixelLeaf, lineWidth: 3)
                        .padding(8)
                }
        }
        .contentShape(Rectangle())
    }

    func handleAccent(for handle: CropHandle) -> Path {
        Path { path in
            switch handle {
            case .topLeading:
                path.move(to: CGPoint(x: 0, y: 12))
                path.addLine(to: .zero)
                path.addLine(to: CGPoint(x: 12, y: 0))
            case .topTrailing:
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 12, y: 0))
                path.addLine(to: CGPoint(x: 12, y: 12))
            case .bottomLeading:
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: 0, y: 12))
                path.addLine(to: CGPoint(x: 12, y: 12))
            case .bottomTrailing:
                path.move(to: CGPoint(x: 12, y: 0))
                path.addLine(to: CGPoint(x: 12, y: 12))
                path.addLine(to: CGPoint(x: 0, y: 12))
            }
        }
    }

    func dimmingLayer(cropRect: CGRect, imageFrame: CGRect) -> some View {
        Path { path in
            path.addRect(imageFrame)
            path.addRect(cropRect)
        }
        .fill(.pixelInk.opacity(0.56), style: FillStyle(eoFill: true))
    }

    func resetCrop() {
        cropRect = activeImageFrame == .zero ? .zero : defaultCropRect(in: activeImageFrame)
        didUserAdjustCrop = false
    }

    func performCrop() {
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

    func moveGesture(in imageFrame: CGRect) -> some Gesture {
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

    func resizeGesture(handle: CropHandle, in imageFrame: CGRect) -> some Gesture {
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

    func defaultCropRect(in imageFrame: CGRect) -> CGRect {
        let width = imageFrame.width * 0.9
        let height = imageFrame.height * 0.9

        return CGRect(
            x: imageFrame.midX - width / 2,
            y: imageFrame.midY - height / 2,
            width: width,
            height: height
        )
    }

    func updateImageFrame(_ imageFrame: CGRect) {
        guard imageFrame.width > 1, imageFrame.height > 1 else { return }

        activeImageFrame = imageFrame
        if !didInitializeCrop || !didUserAdjustCrop {
            cropRect = defaultCropRect(in: imageFrame)
            didInitializeCrop = true
        } else {
            cropRect = clamped(cropRect, in: imageFrame)
        }
    }

    func clamped(_ rect: CGRect, in imageFrame: CGRect) -> CGRect {
        let width = min(max(rect.width, Self.minimumCropLength), imageFrame.width)
        let height = min(max(rect.height, Self.minimumCropLength), imageFrame.height)
        let minX = min(max(rect.minX, imageFrame.minX), imageFrame.maxX - width)
        let minY = min(max(rect.minY, imageFrame.minY), imageFrame.maxY - height)

        return CGRect(x: minX, y: minY, width: width, height: height)
    }

    func resized(
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
}
