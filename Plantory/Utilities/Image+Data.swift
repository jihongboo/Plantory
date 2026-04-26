import SwiftUI
import CoreImage
import CoreGraphics
import UIKit

typealias PlatformImage = UIImage

extension Image {
    init?(data: Data) {
        guard let image = PlatformImage(data: data) else {
            return nil
        }
        self.init(platformImage: image)
    }

    private init(platformImage: PlatformImage) {
        self.init(uiImage: platformImage)
    }
}

extension PlatformImage {
    private static let processingCIContext = CIContext(options: nil)

    static func namedImageData(named name: String) -> Data? {
        return Self(named: name)?.pngData()
    }

    func pngDataRepresentation() -> Data? {
        pngData()
    }

    func normalizedForProcessing() -> PlatformImage {
        guard let cgImage = cgImageForVision else { return self }

        let ciImage = CIImage(cgImage: cgImage)
        let colorSpace = CGColorSpace(name: CGColorSpace.extendedSRGB) ?? CGColorSpaceCreateDeviceRGB()

        guard let normalizedCGImage = Self.processingCIContext.createCGImage(
            ciImage,
            from: ciImage.extent,
            format: .RGBA8,
            colorSpace: colorSpace
        ) else {
            return self
        }

        return PlatformImage(
            cgImage: normalizedCGImage,
            scale: renderScale,
            orientation: renderOrientation
        )
    }

    func resizedToFit(maxPixelDimension: CGFloat) -> PlatformImage {
        let currentMaxDimension = max(size.width, size.height)
        guard currentMaxDimension > maxPixelDimension else { return self }

        let scale = maxPixelDimension / currentMaxDimension
        let targetSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        let rendererFormat = transparentRendererFormat

        return UIGraphicsImageRenderer(size: targetSize, format: rendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func scaled(by ratio: CGFloat) -> PlatformImage {
        guard ratio < 0.999 else { return self }

        let targetSize = CGSize(
            width: max(size.width * ratio, 1),
            height: max(size.height * ratio, 1)
        )

        let rendererFormat = transparentRendererFormat

        return UIGraphicsImageRenderer(size: targetSize, format: rendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    func compressedJPEGData(quality: CGFloat) -> Data? {
        jpegData(compressionQuality: quality)
    }

    var cgImageForVision: CGImage? {
        cgImage
    }

    var visionOrientation: CGImagePropertyOrientation {
        CGImagePropertyOrientation(imageOrientation)
    }
}

enum PlatformImageData {
    static func named(_ name: String) -> Data? {
        PlatformImage.namedImageData(named: name)
    }
}

extension PlatformImage {
    var renderScale: CGFloat { scale }
    var renderOrientation: UIImage.Orientation { imageOrientation }

    private var transparentRendererFormat: UIGraphicsImageRendererFormat {
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = false
        return format
    }
}

private extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
