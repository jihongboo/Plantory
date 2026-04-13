import SwiftUI
import SwiftData

struct PlantPage: View {
    let plant: Plant
    @State private var isPresentingAddLog = false
    
    private var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                PlantPhotoView(photoData: plant.photoData)
                
                CardView {
                    PlantHeaderView(plant: plant)
                }
                         
                CardView(title: "Status") {
                    PlantStatusView(plant: plant)
                }
                
                if let info = plant.information {
                    CardView(title: "Wiki") {
                        PlantWikiCell(info: info)
                    }
                }
                
                CardView(title: "Care Records") {
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
            }
            .scenePadding()
        }
        .navigationTitle(plant.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    isPresentingAddLog = true
                } label: {
                    Label("Add Log", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAddLog) {
            AddLogPage(plant: plant)
        }
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
