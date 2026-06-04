import Foundation
import Observation

@Observable
final class PlantNavigationCoordinator {
    var targetPlantIdentifierPrefix: String?

    func openPlant(withIdentifierPrefix prefix: String) {
        targetPlantIdentifierPrefix = prefix
    }

    func clearTargetPlantIdentifierPrefix() {
        targetPlantIdentifierPrefix = nil
    }
}
