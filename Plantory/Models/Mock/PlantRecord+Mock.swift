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
            id: PlantRecord.monsteraPhotoRecordID,
            createdAt: .now.addingTimeInterval(-3 * 86_400),
            note: "Checked a few yellow edges on older leaves.",
            photoID: PlantRecord.prepareMonsteraPhoto,
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
                id: Self.monsteraPhotoRecordID,
                createdAt: .now.addingTimeInterval(-3 * 86_400),
                note: "Checked a few yellow edges on older leaves.",
                photoID: Self.prepareMonsteraPhoto,
                plant: plant
            )
        ]
    }
}

@MainActor
private extension PlantRecord {
    static let monsteraPhotoRecordID = UUID(uuidString: "9AE7F5F5-5970-4D99-9877-75693626FE73")!
    static let monsteraPhotoID = UUID(uuidString: "9D44A7D7-5B6F-44FE-9C66-1BA55B140305")!

    static var prepareMonsteraPhoto: UUID? {
        guard let photoData = PlatformImageData.monstera else {
            return nil
        }

        try? PlantRecordPhotoStore.shared.savePhotoData(photoData, for: monsteraPhotoID)
        return monsteraPhotoID
    }
}
