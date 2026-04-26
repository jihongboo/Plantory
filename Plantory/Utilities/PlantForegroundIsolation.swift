import CoreImage
import ImageIO
import Vision
import UIKit

enum PlantForegroundIsolation {
    enum IsolationError: LocalizedError {
        case unsupportedImage
        case noForegroundDetected
        case failedToRender

        var errorDescription: String? {
            switch self {
            case .unsupportedImage:
                String(localized: "The selected image could not be prepared for foreground extraction.")
            case .noForegroundDetected:
                String(localized: "Vision could not find a foreground subject in this image.")
            case .failedToRender:
                String(localized: "The foreground result could not be rendered.")
            }
        }
    }

    private static let context = CIContext(options: nil)

    static func isolatePlant(in image: PlatformImage) async throws -> PlatformImage {
        try isolatePlantSync(in: image)
    }

    static func isolatedPNGData(
        from image: PlatformImage,
        maxPixelDimension: CGFloat = ImageCompression.maxPixelDimension,
        compressionRatio: CGFloat = ImageCompression.defaultScaleRatio
    ) async throws -> Data {
        let isolatedImage = try await isolatePlant(in: image)
        guard let data = ImageCompression.compressedPNGData(
            from: isolatedImage,
            maxPixelDimension: maxPixelDimension,
            compressionRatio: compressionRatio
        ) else {
            throw IsolationError.failedToRender
        }
        return data
    }

    static func isolatedPNGData(from imageData: Data) async throws -> Data {
        try await isolatedPNGData(
            from: imageData,
            maxPixelDimension: ImageCompression.maxPixelDimension,
            compressionRatio: ImageCompression.defaultScaleRatio
        )
    }

    static func isolatedPNGData(
        from imageData: Data,
        maxPixelDimension: CGFloat = ImageCompression.maxPixelDimension,
        compressionRatio: CGFloat = ImageCompression.defaultScaleRatio
    ) async throws -> Data {
        guard let image = PlatformImage(data: imageData) else {
            throw IsolationError.unsupportedImage
        }

        return try await isolatedPNGData(
            from: image,
            maxPixelDimension: maxPixelDimension,
            compressionRatio: compressionRatio
        )
    }

    private static func isolatePlantSync(in image: PlatformImage) throws -> PlatformImage {
        guard let cgImage = image.cgImageForVision else {
            throw IsolationError.unsupportedImage
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: image.visionOrientation
        )

        try handler.perform([request])

        guard let observation = request.results?.first,
              !observation.allInstances.isEmpty else {
            throw IsolationError.noForegroundDetected
        }

        let maskedPixelBuffer = try observation.generateMaskedImage(
            ofInstances: observation.allInstances,
            from: handler,
            croppedToInstancesExtent: false,
        )

        let ciImage = CIImage(cvPixelBuffer: maskedPixelBuffer)
        guard let outputCGImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw IsolationError.failedToRender
        }

        return PlatformImage(
            cgImage: outputCGImage,
            scale: image.renderScale,
            orientation: image.renderOrientation
        )
    }
}
