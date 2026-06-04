import Foundation

@MainActor
extension PlantRecord {
    static func previewDiagnosisRecords(for plant: Plant) -> [PlantRecord] {
        [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400),
                plant: plant
            ),
            PlantRecord(
                createdAt: .now.addingTimeInterval(-3 * 86_400),
                note: "Checked a few yellow edges on older leaves.",
                photoData: PlatformImageData.named("Monstera deliciosa"),
                diagnosis: DiagnosisMetadata.overwateringStress,
                plant: plant
            )
        ]
    }

    static func monsteraRecords(for plant: Plant) -> [PlantRecord] {
        [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400),
                plant: plant
            ),
            PlantRecord(
                createdAt: .now.addingTimeInterval(-5 * 86_400),
                note: "Captured new split leaf growth.",
                photoData: PlatformImageData.named("Monstera deliciosa"),
                plant: plant
            )
        ]
    }

    static func cactusWatering(for plant: Plant) -> PlantRecord {
        PlantRecord(
            actionType: .watering,
            createdAt: .now.addingTimeInterval(-10 * 86_400),
            plant: plant
        )
    }
}
