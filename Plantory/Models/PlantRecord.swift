import Foundation
import SwiftUI
import SwiftData

@Model
final class PlantRecord {
    var actionTypeRawValue: String?
    var createdAt: Date = Date()
    var note: String = ""
    @Attribute(.externalStorage)
    var photoData: Data?
    var diagnosis: DiagnosisMetadata?

    var plant: Plant?

    init(
        actionType: RecordActionType,
        createdAt: Date = .now,
        plant: Plant? = nil
    ) {
        self.actionTypeRawValue = actionType.rawValue
        self.createdAt = createdAt
        self.plant = plant
    }

    init(
        createdAt: Date = .now,
        note: String = "",
        photoData: Data?,
        diagnosis: DiagnosisMetadata? = nil,
        plant: Plant? = nil
    ) {
        self.actionTypeRawValue = nil
        self.createdAt = createdAt
        self.note = note
        self.photoData = photoData
        self.diagnosis = diagnosis
        self.plant = plant
    }

    var category: RecordCategory {
        actionType == nil ? .entry : .action
    }

    var actionType: RecordActionType? {
        get {
            guard let actionTypeRawValue else { return nil }
            return RecordActionType(rawValue: actionTypeRawValue)
        }
        set {
            actionTypeRawValue = newValue?.rawValue
        }
    }

    var type: RecordType {
        if let actionType {
            return .action(actionType)
        }
        return .entry
    }
}

enum RecordCategory: String, Codable, CaseIterable, Hashable {
    case action
    case entry

    var label: String {
        switch self {
        case .action: "Action"
        case .entry: "Record"
        }
    }
}

enum RecordActionType: String, Codable, CaseIterable, Hashable, Identifiable {
    var id: RecordActionType { self }
    
    case watering
    case fertilizing
    case pestControl
    case pruning
    case repotting

    var label: String {
        switch self {
        case .watering:     "Watering"
        case .fertilizing:  "Fertilizing"
        case .pestControl:  "Pest Control"
        case .pruning:      "Pruning"
        case .repotting:    "Repotting"
        }
    }
    
    var systemImage: String {
        switch self {
        case .watering: "drop.fill"
        case .fertilizing: "leaf.fill"
        case .pestControl: "ladybug.fill"
        case .pruning: "scissors"
        case .repotting: "arrow.triangle.2.circlepath"
        }
    }
    
    var themeColor: Color {
        switch self {
        case .watering:
            .blue
        case .fertilizing:
            .green
        case .pestControl:
            .orange
        case .pruning:
            .brown
        case .repotting:
            .mint
        }
    }
}

enum RecordType: Hashable {
    case action(RecordActionType)
    case entry

    var label: String {
        switch self {
        case .action(let actionType):
            actionType.label
        case .entry:
            "Record"
        }
    }

    var systemImage: String {
        switch self {
        case .action(let actionType):
            actionType.systemImage
        case .entry:
            "camera.fill"
        }
    }

    var themeColor: Color {
        switch self {
        case .action(let actionType):
            actionType.themeColor
        case .entry:
            .primary
        }
    }
}

struct DiagnosisMetadata: Codable {
    var result: DiagnosisResult
}

// MARK: - AI 诊断结果（附着在记录类条目上）

struct DiagnosisResult: Codable {
    var species: String
    var problem: String
    var causes: [String]
    var suggestions: [String]
    var rawResponse: String
}
