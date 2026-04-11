import Foundation

enum CareTileIndicator {
    case none
    case level(Int)
    case temperature(activeBands: Set<TemperatureBand>)
}

enum TemperatureBand: Int, CaseIterable, Hashable {
    case cool
    case moderate
    case warm
}
