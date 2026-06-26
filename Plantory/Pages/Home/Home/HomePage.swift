//
//  ContentView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI
import SwiftData
import NavigatorUI

struct HomePage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.navigator) private var navigator
    @Environment(PlantNavigationCoordinator.self) private var navigationCoordinator
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    @State private var plantPendingDeletion: Plant?
    @Namespace private var heroNamespace

    private let columns = [GridItem(.adaptive(minimum: 160, maximum: 220), spacing: 14)]

    var body: some View {
        ManagedNavigationStack(scene: "home") {
            PixelPage(backgroundStyle: .primary) {
                VStack {
                    HomeHeaderView()
                    ScrollView {
                        LazyVStack {
                            if plants.isEmpty {
                                PixelContentUnavailableView(error: AppError.empty)
                            } else {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(plants) { plant in
                                        NavigationLink(to: PlantoryDestination.plant(PlantRoute(plantID: plant.id, heroNamespace: heroNamespace))) {
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
                                .animation(.smooth, value: plants)
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
        navigator.push(PlantoryDestination.plant(PlantRoute(plantID: plant.id)))
    }
}
