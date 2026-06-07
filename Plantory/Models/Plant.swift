import Foundation
import SwiftData
import SwiftUI

@Model
final class Plant {
    #Index<Plant>([\.id])

    var id: UUID = UUID()
    var nickname: String?         // 可选别名，例如"我的小绿"
    // 存于 SwiftData 外部文件，CloudKit 同步时自动转为 CKAsset
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date = Date()
    var note: String = ""

    @Relationship(deleteRule: .nullify, inverse: \PlantInformation.plants)
    var plantInformation: PlantInformation?

    // 展示名称：优先用别名，否则使用植物原始信息兜底。
    var displayName: String {
        if let nickname, !nickname.isEmpty { return nickname }
        if let plantInformation { return plantInformation.displayCommonName }
        return String(localized: "Unknown Plant")
    }

    @Relationship(deleteRule: .cascade, inverse: \PlantRecord.plant)
    var records: [PlantRecord]?

    @Relationship(deleteRule: .cascade, inverse: \PlantNotificationSetting.plant)
    var notificationSettings: [PlantNotificationSetting]?

    init(
        id: UUID = UUID(),
        nickname: String? = nil,
        imageData: Data? = nil,
        createdAt: Date = .now,
        note: String = "",
        information: PlantInformation? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.photoData = imageData
        self.createdAt = createdAt
        self.note = note
        self.plantInformation = information
    }
}
