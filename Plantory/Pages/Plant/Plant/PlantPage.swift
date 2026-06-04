import SwiftUI
import SwiftData

struct PlantPage: View {
    @Bindable var plant: Plant
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddLog = false
    @State private var isPresentingEditDetails = false
    
    private var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
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

                    PixelRoundedRectangleCard(fill: Color(.pixelPaper)) {
                        PlantHeaderView(plant: plant)
                    }

                    PixelSectionCard(title: "Plant Status", systemImage: "heart.text.square.fill") {
                        PlantStatusView(plant: plant)
                    }

                    NavigationLink {
                        PlantNotificationsPage(plant: plant)
                    } label: {
                        PixelReminderRow(summary: notificationSummary)
                    }
                    .buttonStyle(.plain)

                    PixelSectionCard(title: "Care Records", systemImage: "list.clipboard.fill") {
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

    @ViewBuilder
    private var careRecordsContent: some View {
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

    private func addActionRecord(_ type: RecordActionType) {
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()

        Task {
            _ = await PlantNotificationScheduler.shared.syncNotifications(for: plant)
        }
    }

    private var notificationSummary: String {
        let enabledCount = plant.notificationSettings?.count(where: \.isEnabled) ?? 0
        let totalCount = plant.notificationSettings?.count ?? PlantNotificationKind.allCases.count

        if enabledCount == 0 {
            return String(localized: "Set watering, fertilizing, and routine reminders.")
        }

        return String(localized: "\(enabledCount) of \(totalCount) reminders enabled")
    }
}

private struct PixelSectionCard<Content: View>: View {
    let title: LocalizedStringKey
    let systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        PixelRoundedRectangleCard(fill: Color(.pixelPaper)) {
            VStack(alignment: .leading, spacing: 14) {
                Label(title, systemImage: systemImage)
                    .font(.pixel(.title2))
                    .foregroundStyle(Color(.pixelInk))
                    .labelIconToTitleSpacing(8)

                PixelDashedDivider()

                content
            }
        }
    }
}

private struct PixelReminderRow: View {
    let summary: String

    var body: some View {
        PixelRoundedRectangleCard(fill: Color(.pixelPaper)) {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.title2.weight(.black))
                    .foregroundStyle(Color(.pixelSun))
                    .frame(width: 42, height: 42)
                    .background(Color(.pixelCream), in: .rect(cornerRadius: 4))
                    .overlay {
                        Rectangle()
                            .stroke(Color(.pixelPaperShadow), lineWidth: 2)
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Care Reminders")
                        .font(.pixel(.title2))
                        .foregroundStyle(Color(.pixelInk))

                    Text(summary)
                        .font(.pixel(.subheadline))
                        .foregroundStyle(Color(.pixelInk).opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.headline.weight(.black))
                    .foregroundStyle(Color(.pixelInk).opacity(0.64))
            }
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
