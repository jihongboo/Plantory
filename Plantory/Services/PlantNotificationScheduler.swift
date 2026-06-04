import Foundation
import SwiftData
import UserNotifications

final class PlantNotificationScheduler {
    static let shared = PlantNotificationScheduler()
    static let notificationCategoryIdentifier = "PLANT_CARE_REMINDER"
    static let completeActionIdentifier = "PLANT_CARE_COMPLETE"
    static let skipActionIdentifier = "PLANT_CARE_SKIP"

    private let center = UNUserNotificationCenter.current()
    private let calendar = Calendar.current
    private let scheduledOccurrencesPerSetting = 8

    private init() {}

    func registerNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: Self.completeActionIdentifier,
            title: String(localized: "Completed"),
            options: []
        )

        let skipAction = UNNotificationAction(
            identifier: Self.skipActionIdentifier,
            title: String(localized: "Skip"),
            options: []
        )

        let category = UNNotificationCategory(
            identifier: Self.notificationCategoryIdentifier,
            actions: [completeAction, skipAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        center.setNotificationCategories([category])
    }

    func syncNotifications(
        for plant: Plant,
        requestAuthorization: Bool = false
    ) async -> PlantNotificationAuthorizationStatus {
        let settings = plant.notificationSettings ?? []
        let enabledSettings = settings.filter(\.isEnabled)

        await cancelNotifications(for: plant, kinds: PlantNotificationKind.allCases)

        guard !enabledSettings.isEmpty else {
            return .notNeeded
        }

        let authorizationStatus = await authorizationStatus(requestIfNeeded: requestAuthorization)
        guard authorizationStatus.canSchedule else {
            return authorizationStatus
        }

        for setting in enabledSettings {
            await scheduleNotifications(for: setting, plant: plant)
        }

        return authorizationStatus
    }

    func syncNotifications(for plants: [Plant]) async {
        let authorizationStatus = await authorizationStatus(requestIfNeeded: false)
        guard authorizationStatus.canSchedule else { return }

        for plant in plants {
            _ = await syncNotifications(for: plant, requestAuthorization: false)
        }
    }

    func cancelNotifications(for plant: Plant) async {
        await cancelNotifications(for: plant, kinds: PlantNotificationKind.allCases)
    }

    func cancelNotifications(forPlantIdentifierPrefix prefix: String) {
        let identifiers = PlantNotificationKind.allCases.flatMap { kind in
            (0..<scheduledOccurrencesPerSetting).map { index in
                "\(prefix).\(kind.rawValue).\(index)"
            }
        }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)
    }

    func scheduleDebugNotification(after seconds: TimeInterval = 10) async -> Bool {
        let authorizationStatus = await authorizationStatus(requestIfNeeded: true)
        guard authorizationStatus.canSchedule else { return false }

        let content = UNMutableNotificationContent()
        content.title = String(localized: "LeafAid Debug")
        content.body = String(localized: "This is a local notification test.")
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "plantory.debug.local",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        )

        do {
            try await center.add(request)
            return true
        } catch {
            assertionFailure("Failed to schedule debug notification: \(error.localizedDescription)")
            return false
        }
    }

    func scheduleDebugPlantNotification(
        for plant: Plant,
        setting: PlantNotificationSetting,
        after seconds: TimeInterval = 10
    ) async -> Bool {
        let authorizationStatus = await authorizationStatus(requestIfNeeded: true)
        guard authorizationStatus.canSchedule else { return false }

        let content = UNMutableNotificationContent()
        content.title = plant.displayName
        content.body = setting.kind.notificationBody(intervalDays: setting.intervalDays)
        content.sound = .default
        content.categoryIdentifier = Self.notificationCategoryIdentifier
        content.userInfo = [
            "plantID": Self.identifierPrefix(for: plant),
            "kind": setting.kind.rawValue,
            "debug": true
        ]

        let request = UNNotificationRequest(
            identifier: "plantory.debug.\(Self.identifierPrefix(for: plant)).\(setting.kind.rawValue)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: max(1, seconds), repeats: false)
        )

        do {
            try await center.add(request)
            return true
        } catch {
            assertionFailure("Failed to schedule debug plant notification: \(error.localizedDescription)")
            return false
        }
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }

    func removeAllPendingNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }

    func handleNotificationResponse(
        _ response: UNNotificationResponse,
        in container: ModelContainer
    ) async {
        let request = response.notification.request
        let userInfo = request.content.userInfo
        let requestIdentifier = request.identifier

        switch response.actionIdentifier {
        case Self.completeActionIdentifier:
            guard
                let plantIdentifier = userInfo["plantID"] as? String,
                let kindRawValue = userInfo["kind"] as? String,
                let kind = PlantNotificationKind(rawValue: kindRawValue)
            else {
                return
            }

            let context = container.mainContext
            let plants = (try? context.fetch(FetchDescriptor<Plant>())) ?? []
            guard let plant = plants.first(where: { Self.identifierPrefix(for: $0) == plantIdentifier }) else {
                return
            }

            let record = PlantRecord(actionType: kind.relatedActionType, plant: plant)
            context.insert(record)

            do {
                try context.save()
            } catch {
                assertionFailure("Failed to save completed notification action: \(error.localizedDescription)")
            }

            center.removeDeliveredNotifications(withIdentifiers: [requestIdentifier])
            center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])
            _ = await syncNotifications(for: plant)

        case Self.skipActionIdentifier:
            center.removeDeliveredNotifications(withIdentifiers: [requestIdentifier])
            center.removePendingNotificationRequests(withIdentifiers: [requestIdentifier])

        default:
            break
        }
    }

    static func identifierPrefix(for plant: Plant) -> String {
        "plant-care.\(String(describing: plant.persistentModelID))"
    }
}

private extension PlantNotificationScheduler {
    func authorizationStatus(requestIfNeeded: Bool) async -> PlantNotificationAuthorizationStatus {
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized:
            return .authorized
        case .provisional:
            return .provisional
        case .ephemeral:
            return .ephemeral
        case .denied:
            return .denied
        case .notDetermined:
            guard requestIfNeeded else { return .notDetermined }

            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                return granted ? .authorized : .denied
            } catch {
                return .denied
            }
        @unknown default:
            return .denied
        }
    }

    func cancelNotifications(for plant: Plant, kinds: [PlantNotificationKind]) async {
        let requestIdentifiers = kinds.flatMap { identifiers(for: $0, plant: plant) }
        center.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
        center.removeDeliveredNotifications(withIdentifiers: requestIdentifiers)
    }

    func scheduleNotifications(for setting: PlantNotificationSetting, plant: Plant) async {
        let dates = nextTriggerDates(for: setting, plant: plant)

        for (index, date) in dates.enumerated() {
            let content = UNMutableNotificationContent()
            content.title = plant.displayName
            content.body = setting.kind.notificationBody(intervalDays: setting.intervalDays)
            content.sound = .default
            content.categoryIdentifier = Self.notificationCategoryIdentifier
            content.userInfo = [
                "plantID": Self.identifierPrefix(for: plant),
                "kind": setting.kind.rawValue
            ]

            let components = calendar.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: date
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: identifiers(for: setting.kind, plant: plant)[index],
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                assertionFailure("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func nextTriggerDates(for setting: PlantNotificationSetting, plant: Plant) -> [Date] {
        let intervalDays = max(1, setting.intervalDays)
        let referenceDate = referenceDate(for: setting, plant: plant)
        let anchorDate = calendar.date(
            bySettingHour: setting.reminderHour,
            minute: setting.reminderMinute,
            second: 0,
            of: referenceDate
        ) ?? referenceDate

        var nextDate = calendar.date(byAdding: .day, value: intervalDays, to: anchorDate) ?? .now
        while nextDate <= .now {
            nextDate = calendar.date(byAdding: .day, value: intervalDays, to: nextDate) ?? .now
        }

        return (0..<scheduledOccurrencesPerSetting).compactMap { offset in
            calendar.date(byAdding: .day, value: intervalDays * offset, to: nextDate)
        }
    }

    func referenceDate(for setting: PlantNotificationSetting, plant: Plant) -> Date {
        guard let latestRelevantRecordDate = latestRelevantRecordDate(for: setting.kind, plant: plant) else {
            return .now
        }
        return latestRelevantRecordDate
    }

    func latestRelevantRecordDate(for kind: PlantNotificationKind, plant: Plant) -> Date? {
        let matchingActionType = kind.relatedActionType
        return (plant.records ?? [])
            .filter { $0.actionType == matchingActionType }
            .map(\.createdAt)
            .max()
    }

    func identifiers(for kind: PlantNotificationKind, plant: Plant) -> [String] {
        let prefix = Self.identifierPrefix(for: plant)
        return (0..<scheduledOccurrencesPerSetting).map { index in
            "\(prefix).\(kind.rawValue).\(index)"
        }
    }
}

enum PlantNotificationAuthorizationStatus {
    case authorized
    case provisional
    case ephemeral
    case denied
    case notDetermined
    case notNeeded

    var canSchedule: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            true
        case .denied, .notDetermined, .notNeeded:
            false
        }
    }
}

private extension PlantNotificationKind {
    var relatedActionType: RecordActionType {
        switch self {
        case .watering:
            .watering
        case .fertilizing:
            .fertilizing
        case .pestCheck:
            .pestControl
        case .pruning:
            .pruning
        case .repotting:
            .repotting
        }
    }

    func notificationBody(intervalDays: Int) -> String {
        switch self {
        case .watering:
            String(localized: "Time to water your plant. Repeat every \(intervalDays) days.")
        case .fertilizing:
            String(localized: "Time to fertilize your plant. Repeat every \(intervalDays) days.")
        case .pestCheck:
            String(localized: "Time for a pest check. Repeat every \(intervalDays) days.")
        case .pruning:
            String(localized: "Time to prune and tidy the plant. Repeat every \(intervalDays) days.")
        case .repotting:
            String(localized: "Check whether the plant needs repotting. Repeat every \(intervalDays) days.")
        }
    }
}
