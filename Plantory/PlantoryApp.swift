import SwiftUI
import SwiftData

@main
struct PlantoryApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: Plant.self, PlantRecord.self, PlantInformation.self)
            let context = container.mainContext
            let count = (try? context.fetchCount(FetchDescriptor<PlantInformation>())) ?? 0
            if count == 0 {
                PlantInformation.catalog.forEach { context.insert($0) }
            }
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
