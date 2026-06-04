import SwiftUI
import SwiftData
import UIKit

struct PlantNotificationsPage: View {
    @Bindable var plant: Plant
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @State private var permissionAlert: NotificationPermissionAlert?

    private var settings: [PlantNotificationSetting] {
        let existing = plant.notificationSettings ?? []
        return existing.sorted { lhs, rhs in
            lhs.kind.sortOrder < rhs.kind.sortOrder
        }
    }

    private var enabledCount: Int {
        settings.count { $0.isEnabled }
    }

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Care Reminders", systemImage: "bell.badge")
                        .font(.headline)

                    Text("Set reminders for watering, fertilizing, pest checks, pruning, and repotting.")
                        .foregroundStyle(.secondary)

                    Text("\(enabledCount) of \(settings.count) reminders enabled")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.tint)
                }
                .padding(.vertical, 4)
            }

            ForEach(settings) { setting in
                Section {
                    PlantNotificationSettingEditor(
                        setting: setting,
                        onToggleChanged: { isEnabled in
                            handleToggleChange(isEnabled, for: setting)
                        },
                        onConfigurationChanged: {
                            handleConfigurationChange()
                        }
                    )
                } footer: {
                    Text(setting.kind.recommendationText(for: plant))
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            ensureDefaultSettings()
        }
        .onDisappear {
            try? modelContext.save()
        }
        .alert(item: $permissionAlert) { alert in
            switch alert {
            case .notificationsDenied:
                Alert(
                    title: Text("Notifications Disabled"),
                    message: Text("Enable notifications for LeafAid in Settings to receive care reminders."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                            openURL(url)
                        } else if let fallbackURL = URL(string: UIApplication.openSettingsURLString) {
                            openURL(fallbackURL)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func ensureDefaultSettings() {
        let existingKinds = Set((plant.notificationSettings ?? []).map(\.kind))

        for kind in PlantNotificationKind.allCases where !existingKinds.contains(kind) {
            let setting = PlantNotificationSetting(
                kind: kind,
                intervalDays: kind.defaultIntervalDays(for: plant),
                reminderHour: kind.defaultReminderHour(for: plant),
                plant: plant
            )
            modelContext.insert(setting)
            if plant.notificationSettings == nil {
                plant.notificationSettings = []
            }
            plant.notificationSettings?.append(setting)
        }

        if !(plant.notificationSettings ?? []).isEmpty {
            try? modelContext.save()
        }
    }

    private func handleToggleChange(_ isEnabled: Bool, for setting: PlantNotificationSetting) {
        Task {
            let status = await PlantNotificationScheduler.shared.syncNotifications(
                for: plant,
                requestAuthorization: isEnabled
            )

            if isEnabled, !status.canSchedule {
                setting.isEnabled = false
                try? modelContext.save()
                permissionAlert = .notificationsDenied
                _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
                return
            }

            try? modelContext.save()
        }
    }

    private func handleConfigurationChange() {
        Task {
            try? modelContext.save()
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }
}

private struct PlantNotificationSettingEditor: View {
    @Bindable var setting: PlantNotificationSetting
    let onToggleChanged: (Bool) -> Void
    let onConfigurationChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Toggle(isOn: $setting.isEnabled) {
                Label(setting.kind.title, systemImage: setting.kind.systemImage)
                    .foregroundStyle(setting.kind.tint)
            }
            .toggleStyle(.switch)
            .onChange(of: setting.isEnabled) { _, isEnabled in
                onToggleChanged(isEnabled)
            }

            VStack(alignment: .leading, spacing: 10) {
                Stepper(value: $setting.intervalDays, in: setting.kind.intervalRange) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Interval")
                        Text(intervalDescription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                DatePicker(
                    "Reminder Time",
                    selection: reminderDateBinding,
                    displayedComponents: .hourAndMinute
                )
            }
            .disabled(!setting.isEnabled)
            .opacity(setting.isEnabled ? 1 : 0.45)
            .onChange(of: setting.intervalDays) { _, _ in
                onConfigurationChanged()
            }
            .onChange(of: setting.reminderHour) { _, _ in
                onConfigurationChanged()
            }
            .onChange(of: setting.reminderMinute) { _, _ in
                onConfigurationChanged()
            }
        }
        .padding(.vertical, 4)
    }

    private var intervalDescription: LocalizedStringKey {
        if setting.intervalDays == 1 {
            return "Every day"
        }
        return "Every \(setting.intervalDays) days"
    }

    private var reminderDateBinding: Binding<Date> {
        Binding(
            get: { setting.reminderDate },
            set: { setting.reminderDate = $0 }
        )
    }
}

private enum NotificationPermissionAlert: Identifiable {
    case notificationsDenied

    var id: Int { 0 }
}

private extension PlantNotificationKind {
    var sortOrder: Int {
        switch self {
        case .watering:
            0
        case .fertilizing:
            1
        case .pestCheck:
            2
        case .pruning:
            3
        case .repotting:
            4
        }
    }
}

#Preview {
    NavigationStack {
        PlantNotificationsPage(plant: .monstera)
    }
    .modelContainer(.preview)
}
