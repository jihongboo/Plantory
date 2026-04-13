import SwiftUI
import SwiftData

struct PlantPage: View {
    @Bindable var plant: Plant
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingAddLog = false
    @State private var isPresentingEditDetails = false
    
    private var sortedRecords: [PlantRecord] {
        (plant.records ?? []).sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
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

                CardView(
                    titleKey: "Notifications",
                    systemImage: "bell.badge"
                ) {
                    NavigationLink {
                        PlantNotificationsPage(plant: plant)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "bell.badge.fill")
                                .font(.title3)
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Configure Care Reminders")
                                    .font(.headline)

                                Text(notificationSummary)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit Details", systemImage: "square.and.pencil") {
                    isPresentingEditDetails = true
                }

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
        .sheet(isPresented: $isPresentingEditDetails) {
            EditPlantDetailsSheet(plant: plant)
        }
    }

    private func addActionRecord(_ type: RecordActionType) {
        let record = PlantRecord(actionType: type, plant: plant)
        modelContext.insert(record)
        try? modelContext.save()

        Task { @MainActor in
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
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
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
            PlantPage(plant: PreviewData.healthyPlant)
        }
        .modelContainer(.preview)
    }
}
