import Foundation
import SwiftData
import SwiftUI

@Model
final class Plant {
    var id: UUID = UUID()
    var nickname: String?         // 可选别名，例如"我的小绿"
    // 存于 SwiftData 外部文件，CloudKit 同步时自动转为 CKAsset
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date = Date()
    var note: String = ""

    // 该植物对应的种类基础信息
    var informationCatalogID: String?
    var informationCommonName: String?
    var informationSpecies: String?
    var informationWaterLevel: String = "medium"
    var informationWater: String = ""
    var informationFertilizerLevel: String = "medium"
    var informationFertilizer: String = ""
    var informationDiseaseRiskLevel: String = "medium"
    var informationCareDifficulty: String = "moderate"

    // 当前存在的健康问题列表（可并发多个）
    var activeIssues: [PlantIssue] = []

    // 整体健康状态从 activeIssues 派生
    // 注意：计算属性不能用于 SwiftData #Predicate 查询
    var healthStatus: HealthStatus {
        guard !activeIssues.isEmpty else { return .healthy }
        let hasSevere = activeIssues.contains { $0.severity == .severe }
        return hasSevere ? .critical : .warning
    }

    // 展示名称：优先用别名，否则读种类通用名，最后兜底
    var displayName: String {
        if let nickname, !nickname.isEmpty { return nickname }
        return informationCommonName ?? String(localized: "Unknown Plant")
    }

    var hasCloudInformation: Bool {
        informationCatalogID?.isEmpty == false
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
        information: PlantInformation? = nil,
    ) {
        self.id = id
        self.nickname = nickname
        self.photoData = imageData
        self.createdAt = createdAt
        self.note = note
        applyInformationSnapshot(information)
    }
}

extension Plant {
    func applyInformationSnapshot(_ information: PlantInformation?) {
        informationCatalogID = information?.catalogID
        informationCommonName = information?.commonName
        informationSpecies = information?.species
        informationWaterLevel = information?.waterLevel ?? "medium"
        informationWater = information?.water ?? ""
        informationFertilizerLevel = information?.fertilizerLevel ?? "medium"
        informationFertilizer = information?.fertilizer ?? ""
        informationDiseaseRiskLevel = information?.diseaseRiskLevel ?? "medium"
        informationCareDifficulty = information?.careDifficulty ?? "moderate"
    }
}

// MARK: - 问题类型

enum IssueType: String, Codable, CaseIterable {
    case underwatered       // 缺水
    case overwatered        // 浇水过多/积水
    case pestInfestation    // 病虫害
    case nutrientDeficiency // 缺肥
    case rootRot            // 根腐病
    case sunburn            // 晒伤
    case insufficientLight  // 光照不足
    case fungalDisease      // 真菌病害
    case other              // 其他

    var label: LocalizedStringKey {
        switch self {
        case .underwatered:       "Underwatered"
        case .overwatered:        "Overwatered"
        case .pestInfestation:    "Pest Infestation"
        case .nutrientDeficiency: "Nutrient Deficiency"
        case .rootRot:            "Root Rot"
        case .sunburn:            "Sunburn"
        case .insufficientLight:  "Insufficient Light"
        case .fungalDisease:      "Fungal Disease"
        case .other:              "Other"
        }
    }

    var systemImage: String {
        switch self {
        case .underwatered:       "drop.slash"
        case .overwatered:        "drop.fill"
        case .pestInfestation:    "ant.fill"
        case .nutrientDeficiency: "leaf.slash"
        case .rootRot:            "xmark.circle"
        case .sunburn:            "sun.max.trianglebadge.exclamationmark"
        case .insufficientLight:  "cloud.sun"
        case .fungalDisease:      "allergens"
        case .other:              "exclamationmark.circle"
        }
    }
}

// MARK: - 严重程度

enum IssueSeverity: String, Codable, Comparable {
    case mild     // 轻微 — 提醒
    case moderate // 中度 — 需要处理
    case severe   // 严重 — 紧急

    static func < (lhs: IssueSeverity, rhs: IssueSeverity) -> Bool {
        let order: [IssueSeverity] = [.mild, .moderate, .severe]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }

    var label: LocalizedStringKey {
        switch self {
        case .mild:     "Mild"
        case .moderate: "Moderate"
        case .severe:   "Severe"
        }
    }
}

// MARK: - 单条问题

struct PlantIssue: Codable, Identifiable {
    var id: String = UUID().uuidString
    var type: IssueType
    var severity: IssueSeverity
    var detectedAt: Date = .now
    var note: String = ""
}

// MARK: - 整体健康状态（派生，用于 UI 展示）

enum HealthStatus {
    case healthy
    case warning
    case critical

    var label: LocalizedStringKey {
        switch self {
        case .healthy:  "Healthy"
        case .warning:  "Needs Attention"
        case .critical: "Critical"
        }
    }

    var systemImage: String {
        switch self {
        case .healthy:  "checkmark.circle.fill"
        case .warning:  "exclamationmark.triangle.fill"
        case .critical: "xmark.octagon.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .healthy:
            .green
        case .warning:
            .orange
        case .critical:
            .red
        }
    }
}
