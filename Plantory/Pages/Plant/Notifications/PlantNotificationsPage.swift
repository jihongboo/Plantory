import SwiftUI
import SwiftData
import UIKit

struct PlantNotificationsPage: View {
    @Bindable var plant: Plant
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(\.modelContext) private var modelContext
    @State private var permissionAlert: NotificationPermissionAlert?

    var body: some View {
        PixelPage {
            ScrollView {
                LazyVStack(spacing: 16) {
                    PixelNotificationsOverviewCard(
                        enabledCount: enabledCount,
                        settingsCount: settings.count
                    )
                    
                    PixelRoundedRectangleCard(title: "Reminder Settings", systemImage: "bell.badge.fill") {
                        VStack(spacing: 0) {
                            ForEach(Array(settings.enumerated()), id: \.element.id) { index, setting in
                                PlantNotificationSettingEditor(
                                    setting: setting,
                                    isEnabled: Binding(
                                        get: { setting.isEnabled },
                                        set: { isEnabled in
                                            setting.isEnabled = isEnabled
                                            handleToggleChange(isEnabled, for: setting)
                                        }
                                    ),
                                    recommendation: setting.kind.recommendationText(for: plant),
                                    onConfigurationChanged: {
                                        handleConfigurationChange()
                                    }
                                )
                                
                                if index < settings.count - 1 {
                                    PixelDashedDivider()
                                }
                            }
                        }
                    }
                }
            }
            .pixelNavigationTitle(title: "Notifications")
        }
        .pixelBottomActionBar {
            Button("Save", systemImage: "checkmark") {
                try? modelContext.save()
                dismiss()
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        }
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

private extension PlantNotificationsPage {
    var settings: [PlantNotificationSetting] {
        let existing = plant.notificationSettings ?? []
        return existing.sorted { lhs, rhs in
            lhs.kind.sortOrder < rhs.kind.sortOrder
        }
    }

    var enabledCount: Int {
        settings.count { $0.isEnabled }
    }

    func ensureDefaultSettings() {
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

    func handleToggleChange(_ isEnabled: Bool, for setting: PlantNotificationSetting) {
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

    func handleConfigurationChange() {
        Task {
            try? modelContext.save()
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }
}
