import Foundation
import SwiftData
import SwiftUI

@Model
final class PlantNotificationSetting {
    var kindRawValue: String = PlantNotificationKind.watering.rawValue
    var isEnabled: Bool = false
    var intervalDays: Int = 7
    var reminderHour: Int = 9
    var reminderMinute: Int = 0

    @Relationship(deleteRule: .nullify)
    var plant: Plant?

    init(
        kind: PlantNotificationKind,
        isEnabled: Bool = false,
        intervalDays: Int = 7,
        reminderHour: Int = 9,
        reminderMinute: Int = 0,
        plant: Plant? = nil
    ) {
        self.kindRawValue = kind.rawValue
        self.isEnabled = isEnabled
        self.intervalDays = intervalDays
        self.reminderHour = reminderHour
        self.reminderMinute = reminderMinute
        self.plant = plant
    }

    var kind: PlantNotificationKind {
        get { PlantNotificationKind(rawValue: kindRawValue) ?? .watering }
        set { kindRawValue = newValue.rawValue }
    }

    var reminderDate: Date {
        get {
            let calendar = Calendar.current
            return calendar.date(
                bySettingHour: reminderHour,
                minute: reminderMinute,
                second: 0,
                of: .now
            ) ?? .now
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 9
            reminderMinute = components.minute ?? 0
        }
    }
}

enum PlantNotificationKind: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }

    case watering
    case fertilizing
    case pestCheck
    case pruning
    case repotting

    var title: LocalizedStringKey {
        switch self {
        case .watering:
            "Watering Reminder"
        case .fertilizing:
            "Fertilizing Reminder"
        case .pestCheck:
            "Pest Check Reminder"
        case .pruning:
            "Pruning Reminder"
        case .repotting:
            "Repotting Reminder"
        }
    }

    var systemImage: String {
        switch self {
        case .watering:
            "drop.fill"
        case .fertilizing:
            "leaf.fill"
        case .pestCheck:
            "ladybug.fill"
        case .pruning:
            "scissors"
        case .repotting:
            "arrow.triangle.2.circlepath"
        }
    }

    var tint: Color {
        switch self {
        case .watering:
            .blue
        case .fertilizing:
            .green
        case .pestCheck:
            .orange
        case .pruning:
            .brown
        case .repotting:
            .mint
        }
    }

    var intervalRange: ClosedRange<Int> {
        switch self {
        case .watering:
            1...30
        case .fertilizing:
            7...120
        case .pestCheck:
            3...60
        case .pruning:
            7...90
        case .repotting:
            30...365
        }
    }

    func defaultIntervalDays(for plant: Plant) -> Int {
        switch self {
        case .watering:
            7
        case .fertilizing:
            30
        case .pestCheck:
            14
        case .pruning:
            30
        case .repotting:
            180
        }
    }

    func defaultReminderHour(for plant: Plant) -> Int {
        switch self {
        case .watering:
            9
        case .fertilizing:
            10
        case .pestCheck:
            19
        case .pruning:
            11
        case .repotting:
            18
        }
    }

    func recommendationText(for plant: Plant) -> String {
        switch self {
        case .watering:
            return PlantInformation.waterDetail(for: "medium")
        case .fertilizing:
            return PlantInformation.fertilizerDetail(for: "medium")
        case .pestCheck:
            return PlantInformation.diseaseRiskDetail(for: "medium")
        case .pruning:
            return PlantInformation.careDifficultyDetail(for: "moderate")
        case .repotting:
            return String(localized: "Use as a long-cycle reminder and adjust when roots outgrow the pot.")
        }
    }
}
