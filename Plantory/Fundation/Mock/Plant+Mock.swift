import Foundation

@MainActor
extension Plant {
    static var healthy: Plant {
        healthy(information: .monstera)
    }

    static func healthy(information: PlantInformation) -> Plant {
        let plant = Plant(
            nickname: "My Monstera",
            imageData: PlatformImageData.named("Monstera deliciosa"),
            note: "Placed near the living room window. New leaf unfurled this week.",
            information: information
        )
        plant.records = PlantRecord.previewDiagnosisRecords(for: plant)
        return plant
    }

    static func pothos(information: PlantInformation = .goldenPothos) -> Plant {
        Plant(nickname: "Happy Pothos", information: information)
    }

    static var warning: Plant {
        warning(information: .cactus)
    }

    static func warning(information: PlantInformation) -> Plant {
        let plant = Plant(nickname: "Desert Star", information: information)
        plant.activeIssues = [PlantIssue(type: .underwatered, severity: .mild)]
        return plant
    }

    static var critical: Plant {
        let plant = Plant(nickname: "Sick Fern")
        plant.activeIssues = [PlantIssue(type: .rootRot, severity: .severe)]
        return plant
    }
}
