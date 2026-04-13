//
//  ContentView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI
import SwiftData

struct HomePage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(PlantNavigationCoordinator.self) private var navigationCoordinator
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    
    @State private var filter: PlantFilter = .all
    @State private var path = NavigationPath()
    @State private var plantPendingDeletion: Plant?
    @Namespace private var heroNamespace
    
    enum PlantFilter: String, CaseIterable {
        case all = "All"
        case healthy = "Healthy"
        case warning = "Needs Attention"

        var title: LocalizedStringKey {
            switch self {
            case .all:
                "All"
            case .healthy:
                "Healthy"
            case .warning:
                "Needs Attention"
            }
        }

        var emptyStateTitle: LocalizedStringKey {
            switch self {
            case .all:
                "No Plants Yet"
            case .healthy:
                "No healthy plants"
            case .warning:
                "No plants needing attention"
            }
        }
    }
    
    private var filteredPlants: [Plant] {
        switch filter {
        case .all:     plants
        case .healthy: plants.filter { $0.healthStatus == .healthy }
        case .warning: plants.filter { $0.healthStatus != .healthy }
        }
    }

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredPlants) { plant in
                        NavigationLink(value: HomeDestination.plant(plant.persistentModelID)) {
                            PlantCardView(plant: plant)
                                .matchedTransitionSource(id: plant.persistentModelID, in: heroNamespace)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                plantPendingDeletion = plant
                            } label: {
                                Label("Delete Plant", systemImage: "trash")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .overlay {
                if filteredPlants.isEmpty {
                    ContentUnavailableView {
                        Label(
                            plants.isEmpty ? "No Plants Yet" : filter.emptyStateTitle,
                            systemImage: "leaf.fill"
                        )
                    } description: {
                        if plants.isEmpty {
                            VStack(spacing: 32) {
                                Text("Add your first plant\nand start tracking its growth")
                            }
                        }
                    } actions: {
                        AddPlantMenuView()
                    }
                    .background(.background)
                }
            }
            .navigationTitle("My Plants")
            .navigationSubtitle("\(filteredPlants.count) plants")
            .confirmationDialog(
                "Delete this plant?",
                isPresented: deletionBinding,
                presenting: plantPendingDeletion
            ) { plant in
                Button(
                    "Delete \(plant.displayName)",
                    role: .destructive
                ) {
                    deletePlant(plant)
                }
                Button("Cancel", role: .cancel) {}
            } message: { plant in
                Text("This will also remove its care records and AI diagnosis history.")
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(PlantFilter.allCases, id: \.self) { option in
                            Button {
                                filter = option
                            } label: {
                                Label(option.title, systemImage: icon(for: option))
                            }
                        }
                    } label: {
                        Label(filter.title, systemImage: "line.3.horizontal.decrease.circle")
                    }

#if DEBUG
                    NavigationLink(value: HomeDestination.debugNotifications) {
                        Label("Debug", systemImage: "ladybug")
                    }
#endif

                    AddPlantMenuView()
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .plant(let identifier):
                    if let plant = plants.first(where: { $0.persistentModelID == identifier }) {
                        PlantPage(plant: plant)
                            .navigationTransition(.zoom(sourceID: plant.persistentModelID, in: heroNamespace))
                    } else {
                        ContentUnavailableView("Plant Not Found", systemImage: "leaf")
                    }

                case .debugNotifications:
                    DebugNotificationsPage()
                }
            }
        }
        .task {
            await PlantNotificationScheduler.shared.syncNotifications(for: plants)
            openPendingPlantIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            Task { @MainActor in
                await PlantNotificationScheduler.shared.syncNotifications(for: plants)
                openPendingPlantIfNeeded()
            }
        }
        .onChange(of: navigationCoordinator.targetPlantIdentifierPrefix) { _, _ in
            openPendingPlantIfNeeded()
        }
        .onChange(of: plants.count) { _, _ in
            openPendingPlantIfNeeded()
        }
    }

    private var deletionBinding: Binding<Bool> {
        Binding(
            get: { plantPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    plantPendingDeletion = nil
                }
            }
        )
    }

    private func icon(for filter: PlantFilter) -> String {
        switch filter {
        case .all:
            "square.grid.2x2"
        case .healthy:
            "checkmark.circle"
        case .warning:
            "exclamationmark.triangle"
        }
    }

    private func deletePlant(_ plant: Plant) {
        let notificationPrefix = PlantNotificationScheduler.identifierPrefix(for: plant)
        plantPendingDeletion = nil
        PlantNotificationScheduler.shared.cancelNotifications(forPlantIdentifierPrefix: notificationPrefix)
        modelContext.delete(plant)
        try? modelContext.save()
    }

    private func openPendingPlantIfNeeded() {
        guard let targetPrefix = navigationCoordinator.targetPlantIdentifierPrefix else { return }
        guard let plant = plants.first(where: { PlantNotificationScheduler.identifierPrefix(for: $0) == targetPrefix }) else {
            return
        }
        navigationCoordinator.clearTargetPlantIdentifierPrefix()
        path.append(HomeDestination.plant(plant.persistentModelID))
    }
}

private enum HomeDestination: Hashable {
    case plant(PersistentIdentifier)
    case debugNotifications
}

#Preview {
    HomePage()
        .modelContainer(.preview)
}

#Preview("Empty") {
    HomePage()
        .modelContainer(.empty)
}
