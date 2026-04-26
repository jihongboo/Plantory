import CoreGraphics
import Foundation
import UIKit

enum ImageCompression {
    struct JPEGProfile {
        let maxPixelDimension: CGFloat
        let maxBytes: Int
        let initialQuality: CGFloat
    }

    static let maxPixelDimension: CGFloat = 1600
    static let maxUploadBytes = 600 * 1024
    static let defaultScaleRatio: CGFloat = 1
    static let minimumScaleRatio: CGFloat = 0.35
    static let scaleRatioStep: CGFloat = 0.1
    static let defaultJPEGQuality: CGFloat = 0.82
    static let minimumJPEGQuality: CGFloat = 0.45
    static let minimumJPEGResizeRatio: CGFloat = 0.55
    static let recognitionUploadProfile = JPEGProfile(
        maxPixelDimension: 1280,
        maxBytes: 350 * 1024,
        initialQuality: 0.76
    )
    static let diagnosisUploadProfile = JPEGProfile(
        maxPixelDimension: 1536,
        maxBytes: 500 * 1024,
        initialQuality: 0.8
    )

    static func compressedJPEGData(
        from image: PlatformImage,
        maxPixelDimension: CGFloat = maxPixelDimension,
        maxBytes: Int = maxUploadBytes,
        compressionQuality: CGFloat = defaultJPEGQuality
    ) -> Data? {
        let baseImage = image.resizedToFit(maxPixelDimension: maxPixelDimension)
        var currentResizeRatio: CGFloat = 1
        var candidateImage = baseImage
        var currentQuality = compressionQuality
        var bestData = candidateImage.compressedJPEGData(quality: currentQuality)

        while let data = bestData, data.count > maxBytes {
            if currentQuality > minimumJPEGQuality {
                currentQuality = max(currentQuality - 0.08, minimumJPEGQuality)
            } else if currentResizeRatio > minimumJPEGResizeRatio {
                currentResizeRatio = max(currentResizeRatio - 0.1, minimumJPEGResizeRatio)
                candidateImage = baseImage.scaled(by: currentResizeRatio)
                currentQuality = compressionQuality
            } else {
                break
            }

            bestData = candidateImage.compressedJPEGData(quality: currentQuality)
        }

        return bestData
    }

    static func compressedJPEGData(
        from image: PlatformImage,
        profile: JPEGProfile
    ) -> Data? {
        compressedJPEGData(
            from: image,
            maxPixelDimension: profile.maxPixelDimension,
            maxBytes: profile.maxBytes,
            compressionQuality: profile.initialQuality
        )
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

    static func compressedJPEGData(
        from imageData: Data,
        profile: JPEGProfile
    ) -> Data? {
        guard let image = PlatformImage(data: imageData) else { return nil }
        return compressedJPEGData(from: image, profile: profile)
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
