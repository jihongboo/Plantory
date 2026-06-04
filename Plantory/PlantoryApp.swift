import SwiftUI
import SwiftData
import UserNotifications

@main
struct PlantoryApp: App {
    let container: ModelContainer
    private let navigationCoordinator: PlantNavigationCoordinator
    private let notificationDelegate: PlantoryNotificationCenterDelegate
    private let weatherService: HomeWeatherService

    init() {
        navigationCoordinator = PlantNavigationCoordinator()
        weatherService = HomeWeatherService()
        let modelContainer: ModelContainer
        do {
            modelContainer = try ModelContainer(
                for: Plant.self,
                PlantRecord.self,
                PlantInformation.self,
                PlantNotificationSetting.self
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

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
                .font(PixelTheme.font(size: 17, relativeTo: .body))
                .tint(.green)
        }
        .environment(navigationCoordinator)
        .environment(\.homeWeatherService, weatherService)
        .modelContainer(container)
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
