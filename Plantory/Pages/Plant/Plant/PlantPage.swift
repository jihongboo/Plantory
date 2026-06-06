import SwiftUI
import SwiftData

struct PlantPage: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var plant: Plant?
    @State private var isPresentingAddLog = false
    @State private var isPresentingEditDetails = false

    private let plantID: UUID?

    init(plant: Plant) {
        plantID = plant.id
        _plant = State(initialValue: plant)
    }

    init(plantID: UUID) {
        self.plantID = plantID
        _plant = State(initialValue: nil)
    }

    var body: some View {
        PixelPage {
            ScrollView {
                if let plant {
                    LazyVStack(spacing: 16) {
                        PixelPlantHeroCard(plant: plant)

                        PlantHeaderView(plant: plant)
                        
                        PixelReminderRow(plant: plant)
                        
                        PlantRecordsView(records: records)
                    }
                }
            }
            .load(load)
            .pixelNavigationTitle(title: plant?.displayName ?? "") {
                Button {
                    isPresentingEditDetails = true
                } label: {
                    Image(systemName: "square.and.pencil")
                        .frame(width: 16, height: 16)
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
        }
        .sheet(isPresented: $isPresentingAddLog) {
            if let plant {
                AddLogPage(plant: plant)
            }
        }
        .sheet(isPresented: $isPresentingEditDetails) {
            if let plant {
                EditPlantDetailsSheet(plant: plant)
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
    
    func addActionRecord(_ type: RecordActionType) {
        guard let plant else { return }
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()
        
        Task {
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }
}
