import SwiftUI
import SwiftData
import UserNotifications

struct DebugNotificationsPage: View {
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]

    @State private var pendingRequests: [UNNotificationRequest] = []
    @State private var statusMessage: String?
    @State private var isLoading = false

    var body: some View {
        List {
            Section("Actions") {
                Button("Send Test Notification (10s)") {
                    sendTestNotification()
                }

                Button("Reload Pending Notifications") {
                    reloadPendingNotifications()
                }

                Button("Resync Plant Notifications") {
                    resyncPlantNotifications()
                }

                Button("Clear All Pending Notifications", role: .destructive) {
                    clearAllPendingNotifications()
                }
            }

            if let statusMessage {
                Section("Status") {
                    Text(statusMessage)
                        .foregroundStyle(.secondary)
                }
            }
            
            Section("Plant Reminder Tests") {
                if plants.isEmpty {
                    Text("No plants available.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(plants) { plant in
                        PlantReminderDebugSection(
                            plant: plant,
                            onScheduled: { message in
                                Task {
                                    statusMessage = message
                                    await loadPendingRequests()
                                }
                            }
                        )
                    }
                }
            }

            Section("Pending Requests") {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if pendingRequests.isEmpty {
                    Text("No pending notifications.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pendingRequests, id: \.identifier) { request in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(request.content.title)
                                .font(.headline)

                            Text(request.identifier)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)

                            Text(triggerDescription(for: request))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
        }
        .navigationTitle("Debug Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPendingRequests()
        }
    }
}

private struct PlantReminderDebugSection: View {
    let plant: Plant
    let onScheduled: (String) -> Void

    private var settings: [PlantNotificationSetting] {
        (plant.notificationSettings ?? []).sorted { $0.kind.rawValue < $1.kind.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(plant.displayName)
                .font(.headline)

            if settings.isEmpty {
                Text("No reminder settings created for this plant yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(settings) { setting in
                    Button {
                        schedule(setting)
                    } label: {
                        HStack {
                            Label(setting.kind.title, systemImage: setting.kind.systemImage)
                            Spacer()
                            Text(setting.isEnabled ? "10s test" : "Disabled setting")
                                .font(.caption)
                                .foregroundStyle(setting.isEnabled ? .secondary : .tertiary)
                        }
                    }
                    .disabled(!setting.isEnabled)
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func schedule(_ setting: PlantNotificationSetting) {
        Task {
            let success = await PlantNotificationScheduler.shared.scheduleDebugPlantNotification(
                for: plant,
                setting: setting
            )
            let reminderName = setting.kind.debugName
            let message = success
                ? "Scheduled \(reminderName) for \(plant.displayName) in 10 seconds."
                : "Unable to schedule \(reminderName) for \(plant.displayName)."
            onScheduled(message)
        }
    }
}

private extension PlantNotificationKind {
    var debugName: String {
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
}

private extension DebugNotificationsPage {
    func sendTestNotification() {
        Task {
            let granted = await PlantNotificationScheduler.shared.scheduleDebugNotification()
            statusMessage = granted
                ? String(localized: "Scheduled a test notification for 10 seconds later.")
                : String(localized: "Notification permission is unavailable. Check system settings.")
            await loadPendingRequests()
        }
    }

    func reloadPendingNotifications() {
        Task {
            await loadPendingRequests()
            statusMessage = String(localized: "Reloaded pending notification requests.")
        }
    }

    func resyncPlantNotifications() {
        Task {
            await PlantNotificationScheduler.shared.syncNotifications(for: plants)
            await loadPendingRequests()
            statusMessage = String(localized: "Resynced all plant notification schedules.")
        }
    }

    func clearAllPendingNotifications() {
        PlantNotificationScheduler.shared.removeAllPendingNotifications()
        Task {
            await loadPendingRequests()
            statusMessage = String(localized: "Removed all pending and delivered notifications.")
        }
    }

    func loadPendingRequests() async {
        isLoading = true
        pendingRequests = await PlantNotificationScheduler.shared.pendingNotificationRequests()
            .sorted { $0.identifier < $1.identifier }
        isLoading = false
    }

    func triggerDescription(for request: UNNotificationRequest) -> String {
        if let trigger = request.trigger as? UNCalendarNotificationTrigger {
            let date = Calendar.current.date(from: trigger.dateComponents)
            if let date {
                return String(localized: "Calendar: \(date.formatted(date: .abbreviated, time: .shortened))")
            }
            return String(localized: "Calendar trigger")
        }

        if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
            return String(localized: "Time interval: \(Int(trigger.timeInterval)) seconds")
        }

        return String(localized: "Unknown trigger")
    }
}

#Preview {
    NavigationStack {
        DebugNotificationsPage()
            .modelContainer(.preview)
    }
}
