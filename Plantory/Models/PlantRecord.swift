import Foundation
import SwiftData

@Model
final class PlantRecord {
    var type: RecordType = RecordType.note
    var createdAt: Date = Date()
    var note: String = ""
    @Attribute(.externalStorage)
    var photoData: Data?
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

enum RecordCategory: String, Codable, CaseIterable, Hashable {
    case care
    case log
    case diagnosis

    var label: String {
        switch self {
        case .care: "Care"
        case .log: "Record"
        case .diagnosis: "AI Diagnosis"
        }
    }
}

enum RecordType: String, Codable, CaseIterable, Hashable {
    case watering       // 浇水
    case fertilizing    // 施肥
    case pestControl    // 除虫
    case photo          // 拍照记录
    case pruning        // 修剪
    case repotting      // 换盆
    case note           // 文字备注
    case diagnosis      // AI 诊断

    var category: RecordCategory {
        switch self {
        case .watering, .fertilizing, .pestControl, .pruning, .repotting:
            .care
        case .photo, .note:
            .log
        case .diagnosis:
            .diagnosis
        }
    }

    var label: String {
        switch self {
        case .watering:     "Watering"
        case .fertilizing:  "Fertilizing"
        case .pestControl:  "Pest Control"
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
        case .pestControl:  "ladybug.fill"
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
    var watering: WateringMetadata?
    var fertilizing: FertilizingMetadata?
    var pestControl: PestControlMetadata?
    var diagnosis: DiagnosisMetadata?

    init(
        watering: WateringMetadata? = nil,
        fertilizing: FertilizingMetadata? = nil,
        pestControl: PestControlMetadata? = nil,
        diagnosis: DiagnosisMetadata? = nil
    ) {
        self.watering = watering
        self.fertilizing = fertilizing
        self.pestControl = pestControl
        self.diagnosis = diagnosis
    }

    enum WaterAmount: String, Codable, Hashable {
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

struct WateringMetadata: Codable {
    var amount: RecordMetadata.WaterAmount
}

struct FertilizingMetadata: Codable {
    var name: String?
    var dilution: String?
}

struct PestControlMetadata: Codable {
    var productName: String?
    var treatmentNotes: String?
}

struct DiagnosisMetadata: Codable {
    var result: DiagnosisResult
}

// MARK: - AI 诊断结果（存于 diagnosis 类型记录的 metadata 中）

struct DiagnosisResult: Codable {
    var species: String
    var problem: String
    var causes: [String]
    var suggestions: [String]
    var rawResponse: String
}
