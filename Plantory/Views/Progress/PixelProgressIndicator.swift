import Foundation

enum PixelProgressIndicator {
    case level(Int)
    case temperature(activeBands: Set<TemperatureBand>)
}

enum TemperatureBand: Int, CaseIterable, Hashable {
    case cool
    case moderate
    case warm
}

extension Set where Element == TemperatureBand {
    var pixelMeterSegments: Set<Int> {
        Swift.Set<Int>(self.map { $0.rawValue + 1 })
    }
}
