import SwiftUI
import SwiftData
import NavigatorUI

struct PlantPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.navigator) private var navigator
    
    @State private var plant: Plant?
    @State private var heroEffect: PlantHeroEffect?

    private let plantID: UUID?
    private let heroNamespace: Namespace.ID?

    init(plant: Plant, heroNamespace: Namespace.ID? = nil) {
        plantID = plant.id
        self.heroNamespace = heroNamespace
        _plant = State(initialValue: plant)
    }

    init(plantID: UUID, heroNamespace: Namespace.ID? = nil) {
        self.plantID = plantID
        self.heroNamespace = heroNamespace
        _plant = State(initialValue: nil)
    }

    var body: some View {
        PixelPage {
            ScrollView {
                if let plant {
                    LazyVStack(spacing: 16) {
                        PlantHeroCard(plant: plant, effect: heroEffect)

                        PlantSummaryView(plant: plant)
                        
                        PlantReminderRow(plant: plant)
                        
                        PlantRecordsView(records: records)
                    }
                }
            }
            .load(load)
            .pixelNavigationTitle(title: Text(verbatim: plant?.displayName ?? "")) {
                if let plant {
                    NavigationLink(to: PlantoryDestination.plantNotifications(PlantRoute(plant: plant))) {
                        Image(systemName: "bell.badge.fill")
                            .frame(width: 16, height: 16)
                    }
                }
                Button {
                    guard let plant else { return }
                    navigator.present(sheet: PlantoryDestination.editPlantDetails(PlantRoute(plant: plant)), managed: true)
                } label: {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 16, height: 16)
                }
            }
        }
        .plantHeroNavigationTransition(sourceID: plantID, namespace: heroNamespace)
        .pixelBottomActionBar {
            Button("Add Log", systemImage: "camera.fill", action: {
                guard let plant else { return }
                navigator.present(sheet: PlantoryDestination.addLog(PlantRoute(plant: plant)), managed: true)
            })
            
            PixelActionMenu(
                "Actions",
                systemImage: "plus.circle.fill",
                items: actionMenuItems
            ) { type in
                addActionRecord(type)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlantPage(plant: .monstera)
    }
    .modelContainer(.preview)
}

private extension View {
    @ViewBuilder
    func plantHeroNavigationTransition(sourceID: UUID?, namespace: Namespace.ID?) -> some View {
        if let sourceID, let namespace {
            navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            self
        }
    }
}

private extension PlantPage {
    func load() async throws {
        guard let plantID else { return }
        var descriptor = FetchDescriptor<Plant>(
            predicate: #Predicate { plant in
                plant.id == plantID
            }
        )
        descriptor.fetchLimit = 1

        plant = try modelContext.fetch(descriptor).first
    }
}

private extension PlantPage {
    var records: [PlantRecord] {
        (plant?.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var actionMenuItems: [PixelActionMenuItem<RecordActionType>] {
        RecordActionType.allCases.map { type in
            PixelActionMenuItem(
                id: type,
                title: type.label,
                systemImage: type.systemImage,
                tint: type.themeColor
            )
        }
    }
    
    func addActionRecord(_ type: RecordActionType) {
        guard let plant else { return }
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()
        triggerHeroEffect(for: type)
        
        Task {
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }

    func triggerHeroEffect(for type: RecordActionType) {
        heroEffect = nil
        heroEffect = PlantHeroEffect(actionType: type)

        Task {
            try? await Task.sleep(for: PlantHeroEffect.displayDuration)
            heroEffect = nil
        }
    }
}
