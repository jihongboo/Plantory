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
            Group {
                if plants.isEmpty {
                    emptyState
                } else {
                    plantGrid
                }
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem {
                    AddPlantMenuView()
                }
            }
        }
    }

    // MARK: - 植物网格
    
    private var plantGrid: some View {
        ScrollView {
            VStack(spacing: 16) {
                Picker("Filter", selection: $filter) {
                    ForEach(PlantFilter.allCases, id: \.self) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                if filteredPlants.isEmpty {
                    filterEmptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredPlants) { plant in
                            PlantCardView(plant: plant)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - 空状态（无植物）
    
    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                )
            
            VStack(spacing: 8) {
                Text("No Plants Yet")
                    .font(.title2.weight(.semibold))
                
                Text("Add your first plant\nand start tracking its growth")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            AddPlantMenuView()
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 筛选无结果
    
    private var filterEmptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 36))
                .foregroundStyle(.secondary)
            
            Text("No \(filter.rawValue) plants")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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
