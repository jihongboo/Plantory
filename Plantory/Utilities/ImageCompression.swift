import CoreGraphics
import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum ImageCompression {
    static let maxPixelDimension: CGFloat = 1600
    static let maxUploadBytes = 600 * 1024
    static let defaultScaleRatio: CGFloat = 1
    static let minimumScaleRatio: CGFloat = 0.35
    static let scaleRatioStep: CGFloat = 0.1
    static let defaultJPEGQuality: CGFloat = 0.82
    static let minimumJPEGQuality: CGFloat = 0.45

    static func compressedJPEGData(
        from image: PlatformImage,
        maxPixelDimension: CGFloat = maxPixelDimension,
        maxBytes: Int = maxUploadBytes,
        compressionQuality: CGFloat = defaultJPEGQuality
    ) -> Data? {
        let resizedImage = image.resizedToFit(maxPixelDimension: maxPixelDimension)
        var currentQuality = compressionQuality
        var bestData = resizedImage.compressedJPEGData(quality: currentQuality)

        while let data = bestData,
              data.count > maxBytes,
              currentQuality > minimumJPEGQuality {
            currentQuality -= 0.08
            bestData = resizedImage.compressedJPEGData(quality: currentQuality)
        }

        return bestData
    }

    static func compressedJPEGData(
        from imageData: Data,
        maxPixelDimension: CGFloat = maxPixelDimension,
        maxBytes: Int = maxUploadBytes,
        compressionQuality: CGFloat = defaultJPEGQuality
    ) -> Data? {
        guard let image = PlatformImage(data: imageData) else { return nil }
        return compressedJPEGData(
            from: image,
            maxPixelDimension: maxPixelDimension,
            maxBytes: maxBytes,
            compressionQuality: compressionQuality
        )
    }

    static func compressedPNGData(
        from image: PlatformImage,
        maxPixelDimension: CGFloat = maxPixelDimension,
        compressionRatio: CGFloat = defaultScaleRatio,
        maxBytes: Int = maxUploadBytes
    ) -> Data? {
        let resizedImage = image.resizedToFit(maxPixelDimension: maxPixelDimension)
        let boundedRatio = min(max(compressionRatio, minimumScaleRatio), 1)

        var currentRatio = boundedRatio
        var candidateImage = resizedImage.scaled(by: currentRatio)
        var bestData = candidateImage.pngDataRepresentation()

        while let data = bestData,
              data.count > maxBytes,
              currentRatio > minimumScaleRatio {
            currentRatio -= scaleRatioStep
            candidateImage = resizedImage.scaled(by: currentRatio)
            bestData = candidateImage.pngDataRepresentation()
        }

        return bestData
    }
}
