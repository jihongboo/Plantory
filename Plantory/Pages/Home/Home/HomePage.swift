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
    
    @State private var path = NavigationPath()
    @State private var plantPendingDeletion: Plant?
    @Namespace private var heroNamespace

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack(path: $path) {
            PixelPage {
                VStack {
                    HomeHeaderView()
                    ScrollView {
                        LazyVStack {
                            HomeWeatherCard()

                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(plants) { plant in
                                    NavigationLink(value: HomeDestination.plant(plant.id)) {
                                        PlantCardView(plant: plant)
                                            .matchedTransitionSource(id: plant.id, in: heroNamespace)
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
                        }
                    }
                }
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
                .navigationDestination(for: HomeDestination.self) { destination in
                    switch destination {
                    case .plant(let plantID):
                        PlantDestinationView(plantID: plantID, heroNamespace: heroNamespace)

                    case .plantInformationLibrary:
                        PlantInformationLibraryPage()

                    case .debugNotifications:
                        DebugNotificationsPage()
                    }
                }
            }
            .pixelBottomActionBar {
                AddPlantMenuView()
            }
            .task {
                await PlantNotificationScheduler.shared.syncNotifications(for: plants)
                openPendingPlantIfNeeded()
            }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task {
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
    }
}

enum HomeDestination: Hashable {
    case plant(UUID)
    case plantInformationLibrary
    case debugNotifications
}

private struct PlantDestinationView: View {
    let plantID: UUID
    let heroNamespace: Namespace.ID

    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    @State private var hasFinishedInitialLookup = false

    var body: some View {
        Group {
            if let plant {
                PlantPage(plant: plant)
                    .navigationTransition(.zoom(sourceID: plant.id, in: heroNamespace))
            } else if hasFinishedInitialLookup {
                PixelContentUnavailableView(
                    "Plant Not Found",
                    systemImage: "leaf",
                    description: "This plant may have been deleted."
                )
            } else {
                ProgressView("Loading Plant")
                    .navigationTitle("Plant")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
        .task(id: plantID) {
            hasFinishedInitialLookup = false
            try? await Task.sleep(for: .milliseconds(350))
            hasFinishedInitialLookup = true
        }
    }
}

#Preview {
    HomePage()
        .modelContainer(.preview)
        .environment(PlantNavigationCoordinator())
}

#Preview("Empty") {
    HomePage()
        .modelContainer(.empty)
        .environment(PlantNavigationCoordinator())
}

private extension HomePage {
    var deletionBinding: Binding<Bool> {
        Binding(
            get: { plantPendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    plantPendingDeletion = nil
                }
            }
        )
    }

    func deletePlant(_ plant: Plant) {
        let notificationPrefix = PlantNotificationScheduler.identifierPrefix(for: plant)
        plantPendingDeletion = nil
        PlantNotificationScheduler.shared.cancelNotifications(forPlantIdentifierPrefix: notificationPrefix)
        modelContext.delete(plant)
        try? modelContext.save()
    }

    func openPendingPlantIfNeeded() {
        guard let targetPrefix = navigationCoordinator.targetPlantIdentifierPrefix else { return }
        guard let plant = plants.first(where: { PlantNotificationScheduler.identifierPrefix(for: $0) == targetPrefix }) else {
            return
        }
        navigationCoordinator.clearTargetPlantIdentifierPrefix()
        path.append(HomeDestination.plant(plant.id))
    }
}

private extension PlantDestinationView {
    var plant: Plant? {
        plants.first { $0.id == plantID }
    }
}
