import SwiftUI
import CoreImage
import CoreGraphics

#if canImport(UIKit)
import UIKit
typealias PlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PlatformImage = NSImage
#endif

extension Image {
    init?(data: Data) {
        #if canImport(UIKit) || canImport(AppKit)
        guard let image = PlatformImage(data: data) else {
            return nil
        }
        self.init(platformImage: image)
        #else
        return nil
        #endif
    }

    #if canImport(UIKit)
    private init(platformImage: PlatformImage) {
        self.init(uiImage: platformImage)
    }
    #elseif canImport(AppKit)
    private init(platformImage: PlatformImage) {
        self.init(nsImage: platformImage)
    }
    #endif
}

#if canImport(UIKit) || canImport(AppKit)
extension PlatformImage {
    private static let processingCIContext = CIContext(options: nil)

    static func namedImageData(named name: String) -> Data? {
        #if canImport(UIKit)
        return Self(named: name)?.pngData()
        #elseif canImport(AppKit)
        guard let image = Self(named: NSImage.Name(name)) else {
            return nil
        }
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
        #endif
    }

    func pngDataRepresentation() -> Data? {
        #if canImport(UIKit)
        pngData()
        #elseif canImport(AppKit)
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        return bitmap.representation(using: .png, properties: [:])
        #endif
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

        #if canImport(UIKit)
        return PlatformImage(
            cgImage: normalizedCGImage,
            scale: renderScale,
            orientation: renderOrientation
        )
        #elseif canImport(AppKit)
        return PlatformImage(cgImage: normalizedCGImage, size: ciImage.extent.size)
        #endif
    }

    func resizedToFit(maxPixelDimension: CGFloat) -> PlatformImage {
        let currentMaxDimension = max(size.width, size.height)
        guard currentMaxDimension > maxPixelDimension else { return self }

        let scale = maxPixelDimension / currentMaxDimension
        let targetSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        #if canImport(UIKit)
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1

        return UIGraphicsImageRenderer(size: targetSize, format: rendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
        #elseif canImport(AppKit)
        let image = NSImage(size: targetSize)
        image.lockFocus()
        draw(
            in: CGRect(origin: .zero, size: targetSize),
            from: CGRect(origin: .zero, size: size),
            operation: .copy,
            fraction: 1
        )
        image.unlockFocus()
        return image
        #endif
    }

    func scaled(by ratio: CGFloat) -> PlatformImage {
        guard ratio < 0.999 else { return self }

        let targetSize = CGSize(
            width: max(size.width * ratio, 1),
            height: max(size.height * ratio, 1)
        )

        #if canImport(UIKit)
        let rendererFormat = UIGraphicsImageRendererFormat.default()
        rendererFormat.scale = 1

        return UIGraphicsImageRenderer(size: targetSize, format: rendererFormat).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
        #elseif canImport(AppKit)
        let image = NSImage(size: targetSize)
        image.lockFocus()
        draw(
            in: CGRect(origin: .zero, size: targetSize),
            from: CGRect(origin: .zero, size: size),
            operation: .copy,
            fraction: 1
        )
        image.unlockFocus()
        return image
        #endif
    }

    func compressedJPEGData(quality: CGFloat) -> Data? {
        #if canImport(UIKit)
        jpegData(compressionQuality: quality)
        #elseif canImport(AppKit)
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        return bitmap.representation(
            using: .jpeg,
            properties: [.compressionFactor: quality]
        )
        #endif
    }

    var cgImageForVision: CGImage? {
        #if canImport(UIKit)
        cgImage
        #elseif canImport(AppKit)
        cgImage(forProposedRect: nil, context: nil, hints: nil)
        #endif
    }

    var visionOrientation: CGImagePropertyOrientation {
        #if canImport(UIKit)
        CGImagePropertyOrientation(imageOrientation)
        #elseif canImport(AppKit)
        .up
        #endif
    }
}

enum PlatformImageData {
    static func named(_ name: String) -> Data? {
        PlatformImage.namedImageData(named: name)
    }
}
#endif

#if canImport(UIKit)
extension PlatformImage {
    var renderScale: CGFloat { scale }
    var renderOrientation: UIImage.Orientation { imageOrientation }
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
#endif
