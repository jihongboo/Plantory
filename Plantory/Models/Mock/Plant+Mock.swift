import Foundation

@MainActor
extension Plant {
    static var monstera: Plant = {
        let plant = Plant(
            nickname: "My Monstera",
            imageData: PlatformImageData.monstera,
            note: "Placed near the living room window. New leaf unfurled this week.",
            information: .monstera,
        )
        plant.records = PlantRecord.mock(for: plant)
        return plant
    }()
    
    static var succulent: Plant = {
        let plant = Plant(
            nickname: "My Succulent",
            imageData: PlatformImageData.succulent,
            note: "Placed put it under the sun.",
            information: .succulent,
        )
        plant.records = PlantRecord.mock(for: plant)
        return plant
    }()
}
