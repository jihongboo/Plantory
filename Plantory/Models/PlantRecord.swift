import Foundation
import SwiftUI
import SwiftData

@Model
final class PlantRecord {
    #Index<PlantRecord>([\.id])

    var id: UUID = UUID()
    var actionType: RecordActionType?
    var createdAt: Date = Date()
    var note: String = ""
    var photoID: UUID?

    var plant: Plant?

    init(
        id: UUID = UUID(),
        actionType: RecordActionType? = nil,
        createdAt: Date = .now,
        note: String = "",
        photoID: UUID? = nil,
        plant: Plant? = nil
    ) {
        self.id = id
        self.actionType = actionType
        self.createdAt = createdAt
        self.note = note
        self.photoID = photoID
        self.plant = plant
    }

    var hasPhoto: Bool {
        photoID != nil
    }

    @MainActor
    var displayLabel: LocalizedStringKey {
        if let actionType {
            return actionType.label
        }
        if hasPhoto {
            return "Photo Record"
        }
        return "Record"
    }

    @MainActor
    var displaySystemImage: String {
        if let actionType {
            return actionType.systemImage
        }
        if hasPhoto {
            return "camera.fill"
        }
        return "note.text"
    }

    @MainActor
    var displayThemeColor: Color {
        if let actionType {
            return actionType.themeColor
        }
        if hasPhoto {
            return .pixelLeaf
        }
        return .pixelPaperShadow
    }
}

enum RecordActionType: String, Codable, CaseIterable, Hashable, Identifiable {
    var id: RecordActionType { self }
    
    case watering
    case fertilizing
    case pestControl
    case pruning
    case repotting

    var label: LocalizedStringKey {
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
