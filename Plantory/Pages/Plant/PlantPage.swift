import SwiftUI
import SwiftData

struct PlantPage: View {
    let plant: Plant
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddLog = false
    
    private var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                Text(plant.information?.tips ?? "")
                PlantPhotoView(photoData: plant.photoData)
                    .frame(height: 300)
                
                CardView {
                    PlantHeaderView(plant: plant)
                }
                         
                CardView(
                    titleKey: "Status",
                    systemImage: "stethoscope"
                ) {
                    PlantStatusView(plant: plant)
                }

                LazyVStack {
                    Text("Care Records")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CardView {
                        if sortedRecords.isEmpty {
                            VStack {
                                Label("No Records Yet", systemImage: "clock.arrow.circlepath")
                                    .font(.headline)
                                
                                Text("Watering, fertilizing, pest control, and photo records will appear here.")
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            ForEach(sortedRecords) { record in
                                PlantRecordCard(record: record)
                                Divider()
                            }
                        }
                    }
                    .animation(.smooth, value: sortedRecords)
                }
            }
            .scenePadding()
        }
        .navigationTitle(plant.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Menu("Add Log", systemImage: "plus") {
                    Button("Add Log", systemImage: "camera.fill") {
                        isPresentingAddLog = true
                    }

                    ForEach(RecordActionType.allCases) { type in
                        Button(type.label, systemImage: type.systemImage) {
                            addActionRecord(type)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddLog) {
            AddLogPage(plant: plant)
        }
    }

    private func addActionRecord(_ type: RecordActionType) {
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
    }
}

#Preview {
    HeroPlantPagePreview()
}

private struct HeroPlantPagePreview: View {
    var body: some View {
        NavigationStack {
            PlantPage(plant: PreviewData.healthyPlant)
        }
        .modelContainer(.preview)
    }
}
