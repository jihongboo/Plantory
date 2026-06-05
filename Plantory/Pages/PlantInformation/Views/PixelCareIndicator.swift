import Foundation

enum PixelCareIndicator {
    case level(Int)
    case temperature(activeBands: Set<TemperatureBand>)
}
