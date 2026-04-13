import SwiftUI
import SwiftData

@main
struct PlantoryApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Plant.self, PlantRecord.self, PlantInformation.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            HomePage()
        }
        .modelContainer(container)
    }
}
