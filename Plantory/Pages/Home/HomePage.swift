//
//  ContentView.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI
import SwiftData

struct HomePage: View {
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]
    
    @State private var filter: PlantFilter = .all
    @Namespace private var heroNamespace
    
    enum PlantFilter: String, CaseIterable {
        case all = "All"
        case healthy = "Healthy"
        case warning = "Needs Attention"
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
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredPlants) { plant in
                        NavigationLink {
                            PlantPage(plant: plant)
                                .navigationTransition(.zoom(sourceID: plant.persistentModelID, in: heroNamespace))
                        } label: {
                            PlantCardView(plant: plant)
                                .matchedTransitionSource(id: plant.persistentModelID, in: heroNamespace)
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
                            plants.isEmpty ? "No Plants Yet" : "No \(filter.rawValue) plants",
                            systemImage: "leaf.fill"
                        )
                    } description: {
                        if plants.isEmpty {
                            VStack(spacing: 32) {
                                Text("Add your first plant\nand start tracking its growth")
                                AddPlantMenuView()
                            }
                        }
                    }
                    .background(.background)
                }
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        ForEach(PlantFilter.allCases, id: \.self) { option in
                            Button {
                                filter = option
                            } label: {
                                Label(option.rawValue, systemImage: icon(for: option))
                            }
                        }
                    } label: {
                        Label(filter.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                    }

                    AddPlantMenuView()
                }
            }
        }
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
}

#Preview {
    HomePage()
        .modelContainer(.preview)
}

#Preview("Empty") {
    HomePage()
        .modelContainer(.empty)
}
