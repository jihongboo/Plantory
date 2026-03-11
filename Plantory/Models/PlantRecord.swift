import Foundation
import SwiftData

@Model
final class PlantRecord {
    var type: RecordType = RecordType.note
    var createdAt: Date = Date()
    var note: String = ""
    @Attribute(.externalStorage) var photoData: Data?
    var metadata: RecordMetadata?

    var plant: Plant?

    init(
        type: RecordType,
        createdAt: Date = .now,
        note: String = "",
        photoData: Data? = nil,
        metadata: RecordMetadata? = nil,
        plant: Plant? = nil
    ) {
        self.type = type
        self.createdAt = createdAt
        self.note = note
        self.photoData = photoData
        self.metadata = metadata
        self.plant = plant
    }
}

// MARK: - 记录类型

enum RecordType: String, Codable, CaseIterable {
    case watering       // 浇水
    case fertilizing    // 施肥
    case photo          // 拍照记录
    case pruning        // 修剪
    case repotting      // 换盆
    case note           // 文字备注
    case diagnosis      // AI 诊断

    var label: String {
        switch self {
        case .watering:     "Watering"
        case .fertilizing:  "Fertilizing"
        case .photo:        "Photo"
        case .pruning:      "Pruning"
        case .repotting:    "Repotting"
        case .note:         "Note"
        case .diagnosis:    "AI Diagnosis"
        }
    }

    var systemImage: String {
        switch self {
        case .watering:     "drop.fill"
        case .fertilizing:  "leaf.fill"
        case .photo:        "camera.fill"
        case .pruning:      "scissors"
        case .repotting:    "arrow.triangle.2.circlepath"
        case .note:         "note.text"
        case .diagnosis:    "stethoscope"
        }
    }
}

// MARK: - 附加元数据

struct RecordMetadata: Codable {
    // 浇水
    var waterAmount: WaterAmount?

    // 施肥
    var fertilizerName: String?
    var fertilizerDilution: String?

    // AI 诊断结果
    var diagnosisResult: DiagnosisResult?

    enum WaterAmount: String, Codable {
        case little, normal, plenty

        var label: String {
            switch self {
            case .little: "A Little"
            case .normal: "Normal"
            case .plenty: "Plenty"
            }
        }
    }
}

// MARK: - AI 诊断结果（存于 diagnosis 类型记录的 metadata 中）

struct DiagnosisResult: Codable {
    var species: String
    var problem: String
    var causes: [String]
    var suggestions: [String]
    var rawResponse: String
}
