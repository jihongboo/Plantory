import SwiftUI
import SwiftData
import UserNotifications

@main
struct PlantoryApp: App {
    let container: ModelContainer
    private let navigationCoordinator: PlantNavigationCoordinator
    private let notificationDelegate: PlantoryNotificationCenterDelegate

    init() {
        navigationCoordinator = PlantNavigationCoordinator()
        let modelContainer = Self.makeModelContainer()

        container = modelContainer
        notificationDelegate = PlantoryNotificationCenterDelegate(
            container: modelContainer,
            navigationCoordinator: navigationCoordinator
        )

        if !AppEnvironment.isPreview {
            PlantNotificationScheduler.shared.registerNotificationCategories()
            UNUserNotificationCenter.current().delegate = notificationDelegate
        }
    }

    var body: some Scene {
        WindowGroup {
            HomePage()
                .font(.pixel(.body))
                .tint(.green)
        }
        .environment(navigationCoordinator)
        .modelContainer(container)
    }
}

private extension PlantoryApp {
    static func makeModelContainer() -> ModelContainer {
        do {
            let schema = Schema([
                Plant.self,
                PlantInformation.self,
                PlantRecord.self,
                PlantNotificationSetting.self
            ])

            let configuration = ModelConfiguration(schema: schema)
            return try ModelContainer(for: schema, configurations: configuration)
        } catch {
            fatalError("Failed to create ModelContainer after resetting store: \(error)")
        }
    }
}

private final class PlantoryNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let container: ModelContainer
    private let navigationCoordinator: PlantNavigationCoordinator

    init(
        container: ModelContainer,
        navigationCoordinator: PlantNavigationCoordinator
    ) {
        self.container = container
        self.navigationCoordinator = navigationCoordinator
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier,
           let plantIdentifier = response.notification.request.content.userInfo["plantID"] as? String {
            navigationCoordinator.openPlant(withIdentifierPrefix: plantIdentifier)
        }

        await PlantNotificationScheduler.shared.handleNotificationResponse(response, in: container)
    }
}
