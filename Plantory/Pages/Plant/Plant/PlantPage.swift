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
            .scenePadding()
            .padding(.bottom, 92)
        }
        .background {
            PixelPlantDetailBackground()
        }
        .toolbar(.hidden, for: .navigationBar)
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
                    .font(.pixel(size: 22, relativeTo: .headline))
                    .foregroundStyle(Color(.pixelInk))

                Text("Watering, fertilizing, pest control, and photo records will appear here.")
                    .font(.pixel(size: 16, relativeTo: .subheadline))
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

private struct PixelPlantDetailBackground: View {
    var body: some View {
        PageBackground()
            .overlay {
                LinearGradient(
                    colors: [
                        Color(.pixelLeafDark).opacity(0.72),
                        Color(.pixelLeafDark).opacity(0.9),
                        Color(.pixelInk).opacity(0.88)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
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
                    .font(.pixel(size: 22, relativeTo: .title3))
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
                        .font(.pixel(size: 22, relativeTo: .headline))
                        .foregroundStyle(Color(.pixelInk))

                    Text(summary)
                        .font(.pixel(size: 15, relativeTo: .subheadline))
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

private struct PixelDashedDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(.pixelPaperShadow).opacity(0.42))
            .frame(height: 2)
            .overlay(alignment: .leading) {
                HStack(spacing: 6) {
                    ForEach(0..<36, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(.pixelPaper))
                            .frame(width: 4, height: 2)
                    }
                }
            }
    }
}

private struct EditPlantDetailsSheet: View {
    let plant: Plant

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var nickname: String
    @State private var note: String

    init(plant: Plant) {
        self.plant = plant
        _nickname = State(initialValue: plant.nickname ?? "")
        _note = State(initialValue: plant.note)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Details") {
                    TextField("Nickname", text: $nickname)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note")
                            .font(.headline)

                        TextField(
                            "Add a note about this plant",
                            text: $note,
                            axis: .vertical
                        )
                        .lineLimit(4...8)
                    }
                }

                if let commonName = plant.information?.commonName {
                    Section("Plant") {
                        LabeledContent("Recognized As", value: commonName)

                        if let species = plant.information?.species {
                            LabeledContent("Species", value: species)
                        }
                    }
                }
            }
            .navigationTitle("Edit Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .bold()
                }
            }
        }
    }

    private func saveChanges() {
        let trimmedNickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        plant.nickname = trimmedNickname.isEmpty ? nil : trimmedNickname
        plant.note = trimmedNote

        try? modelContext.save()
        dismiss()
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
