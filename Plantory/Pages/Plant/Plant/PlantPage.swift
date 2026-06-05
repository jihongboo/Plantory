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
                    PixelNavigationBar(title: plant.displayName) {
                        Button {
                            isPresentingEditDetails = true
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.pixelRectangle)
                    }
                    
                    PixelPlantHeroCard(plant: plant)
                    
                    PlantHeaderView(plant: plant)
                    
                    PixelRoundedRectangleCard(title: "Plant Status", systemImage: "heart.text.square.fill") {
                        PlantStatusView(plant: plant)
                    }
                    
                    NavigationLink {
                        PlantNotificationsPage(plant: plant)
                    } label: {
                        PixelReminderRow(summary: notificationSummary)
                    }
                    .buttonStyle(.plain)
                    
                    PixelRoundedRectangleCard(title: "Care Records", systemImage: "list.clipboard.fill") {
                        careRecordsContent
                    }
                    .animation(.smooth, value: sortedRecords)
                }
            }
        }
        .pixelBottomActionBar {
            Button("Add Log", systemImage: "camera.fill", action: {
                isPresentingAddLog = true
            })
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            
            Menu("Actions", systemImage: "plus.circle.fill") {
                ForEach(RecordActionType.allCases) { type in
                    Button(type.label, systemImage: type.systemImage) {
                        addActionRecord(type)
                    }
                }
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
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
    HeroPlantPagePreview()
}

private struct HeroPlantPagePreview: View {
    var body: some View {
        NavigationStack {
            PlantPage(plant: .monstera)
        }
        .modelContainer(.preview)
    }
}

private extension PlantPage {
    var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    @ViewBuilder
    var careRecordsContent: some View {
        if sortedRecords.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color(.pixelLeaf))
                
                Text("No Records Yet")
                    .font(.pixel(.title2))
                    .foregroundStyle(Color(.pixelInk))
                
                Text("Watering, fertilizing, pest control, and photo records will appear here.")
                    .font(.pixel(.callout))
                    .foregroundStyle(Color(.pixelInk).opacity(0.68))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        } else {
            VStack(spacing: 0) {
                ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
                    PlantRecordCard(record: record)
                    
                    if index < sortedRecords.count - 1 {
                        PixelDashedDivider()
                    }
                }
            }
        }
    }
    
    func addActionRecord(_ type: RecordActionType) {
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()
        
        Task {
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }
    
    var notificationSummary: String {
        let enabledCount = plant.notificationSettings?.count(where: \.isEnabled) ?? 0
        let totalCount = plant.notificationSettings?.count ?? PlantNotificationKind.allCases.count
        
        if enabledCount == 0 {
            return String(localized: "Set watering, fertilizing, and routine reminders.")
        }
        
        return String(localized: "\(enabledCount) of \(totalCount) reminders enabled")
    }
}
