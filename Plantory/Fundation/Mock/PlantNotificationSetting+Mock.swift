import Foundation

@MainActor
extension PlantNotificationSetting {
    static func watering(for plant: Plant) -> PlantNotificationSetting {
        PlantNotificationSetting(
            kind: .watering,
            isEnabled: true,
            intervalDays: PlantNotificationKind.watering.defaultIntervalDays(for: plant),
            reminderHour: PlantNotificationKind.watering.defaultReminderHour(for: plant),
            plant: plant
        )
    }
}
