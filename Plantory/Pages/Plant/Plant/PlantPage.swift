import SwiftUI
import SwiftData

struct PlantPage: View {
    @Bindable var plant: Plant
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddLog = false
    @State private var isPresentingEditDetails = false
    
    
    var body: some View {
        PixelPage {
            ScrollView {
                LazyVStack(spacing: 16) {
                    PixelPlantHeroCard(plant: plant)
                    
                    PlantHeaderView(plant: plant)
                    
                    PixelReminderRow(plant: plant)
                    
                    PlantRecordsView(records: records)
                }
            }
            .pixelNavigationTitle(title: plant.displayName) {
                Button {
                    isPresentingEditDetails = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 16, height: 16)
                }
            }
        }
        .pixelBottomActionBar {
            Button("Add Log", systemImage: "camera.fill", action: {
                isPresentingAddLog = true
            })
            
            Menu("Actions", systemImage: "plus.circle.fill") {
                ForEach(RecordActionType.allCases) { type in
                    Button(type.label, systemImage: type.systemImage) {
                        addActionRecord(type)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingAddLog) {
            AddLogPage(plant: plant)
        }
        .sheet(isPresented: $isPresentingEditDetails) {
            EditPlantDetailsSheet(plant: plant)
        }
    }
    
}

#Preview {
    NavigationStack {
        PlantPage(plant: .monstera)
    }
    .modelContainer(.preview)
}

private extension PlantPage {
    var records: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    func addActionRecord(_ type: RecordActionType) {
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()
        
        Task {
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }
}
