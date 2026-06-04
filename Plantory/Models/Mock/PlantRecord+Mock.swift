import Foundation

@MainActor
extension PlantRecord {
    static let monstera = [
        PlantRecord(
            actionType: .watering,
            createdAt: .now.addingTimeInterval(-86_400),
            plant: .monstera
        ),
        PlantRecord(
            createdAt: .now.addingTimeInterval(-3 * 86_400),
            note: "Checked a few yellow edges on older leaves.",
            photoData: PlatformImageData.monstera,
            diagnosis: DiagnosisMetadata.overwateringStress,
            plant: .monstera
        )
    ]
    
    static func mock(for plant: Plant) -> [PlantRecord] {
        [
            PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400),
                plant: plant
            ),
            PlantRecord(
                createdAt: .now.addingTimeInterval(-3 * 86_400),
                note: "Checked a few yellow edges on older leaves.",
                photoData: PlatformImageData.monstera,
                diagnosis: DiagnosisMetadata.overwateringStress,
                plant: plant
            )
        ]
    }
}
