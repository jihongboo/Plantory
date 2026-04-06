import SwiftUI
import SwiftData

struct AddCareRecordPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let plant: Plant
    
    @State private var selectedType: RecordType = .watering
    @State private var createdAt: Date = .now
    @State private var note = ""
    @State private var waterAmount: RecordMetadata.WaterAmount = .normal
    @State private var fertilizerName = ""
    @State private var fertilizerDilution = ""
    @State private var pesticideName = ""
    @State private var pestNotes = ""
    @State private var recordImage: PlatformImage?
    
    private let supportedTypes = RecordType.allCases.filter { $0.category == .care }
    private let gridColumns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Record Type") {
                    typeSection
                    
                    typeDetailsSection
                }
                
                Section("Record Detail") {
                    DatePicker("Time", selection: $createdAt)
                        .font(.headline)

                    photoSection
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        TextField(notePlaceholder, text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }
            }
            .navigationTitle("Add Care Record")
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
                        saveRecord()
                    }
                    .bold()
                }
            }
        }
    }
    
    private var typeSection: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(supportedTypes, id: \.self) { type in
                Button {
                    selectedType = type
                } label: {
                    recordTypeCard(type)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private var typeDetailsSection: some View {
        switch selectedType {
        case .watering:
            VStack(alignment: .leading, spacing: 14) {
                Text("Watering")
                    .font(.headline)
                
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach([RecordMetadata.WaterAmount.little, .normal, .plenty], id: \.self) { amount in
                        Button {
                            waterAmount = amount
                        } label: {
                            amountCard(amount)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        case .fertilizing:
            VStack(alignment: .leading, spacing: 14) {
                Text("Fertilizing")
                    .font(.headline)
                
                TextField("Fertilizer name", text: $fertilizerName)
                TextField("Dilution ratio", text: $fertilizerDilution)
            }
        case .pestControl:
            VStack(alignment: .leading, spacing: 14) {
                Text("Pest Control")
                    .font(.headline)
                
                TextField("Product or method", text: $pesticideName)
                TextField("Target pest or notes", text: $pestNotes, axis: .vertical)
                    .lineLimit(2...4)
            }
        case .pruning:
            typeHint(
                title: "Pruning",
                description: "Record trimming, dead leaf removal, or shaping work for this plant."
            )
        case .repotting:
            typeHint(
                title: "Repotting",
                description: "Use notes to record pot size, soil mix, root condition, or aftercare."
            )
        case .photo:
            typeHint(
                title: "Photo Record",
                description: "Add a progress photo to track growth, recovery, or seasonal changes."
            )
        case .note:
            typeHint(
                title: "Care Note",
                description: "Save a general maintenance note that does not fit other record types."
            )
        default:
            EmptyView()
        }
    }
}

private extension AddCareRecordPage {
    var photoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Photo")
                    .font(.headline)

                Text("Optional. Add a photo together with this record.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            RecordPhotoButton(image: $recordImage)
                .aspectRatio(1.8, contentMode: .fit)
        }
    }

    var notePlaceholder: String {
        switch selectedType {
        case .watering:
            "How was the soil moisture?"
        case .fertilizing:
            "Add any feeding notes"
        case .pestControl:
            "Describe what you treated"
        case .pruning:
            "What did you prune or clean up?"
        case .repotting:
            "What changed during repotting?"
        case .photo:
            "What does this photo capture?"
        case .note:
            "Add a care note"
        default:
            "Add notes"
        }
    }

    var cardStroke: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(.white.opacity(0.35), lineWidth: 1)
    }
    
    var compressedPhotoData: Data? {
        guard let recordImage else { return nil }
        return ImageCompression.compressedJPEGData(from: recordImage)
    }
    
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func saveRecord() {
        let record = PlantRecord(
            type: selectedType,
            createdAt: createdAt,
            note: trimmed(note),
            photoData: compressedPhotoData,
            metadata: metadata,
            plant: plant
        )
        
        modelContext.insert(record)
        dismiss()
    }
    
    var metadata: RecordMetadata? {
        switch selectedType {
        case .watering:
            return RecordMetadata(
                watering: WateringMetadata(amount: waterAmount)
            )
        case .fertilizing:
            let name = trimmed(fertilizerName)
            let dilution = trimmed(fertilizerDilution)
            return RecordMetadata(
                fertilizing: FertilizingMetadata(
                    name: name.isEmpty ? nil : name,
                    dilution: dilution.isEmpty ? nil : dilution
                )
            )
        case .pestControl:
            let pesticide = trimmed(pesticideName)
            let notes = trimmed(pestNotes)
            return RecordMetadata(
                pestControl: PestControlMetadata(
                    productName: pesticide.isEmpty ? nil : pesticide,
                    treatmentNotes: notes.isEmpty ? nil : notes
                )
            )
        case .photo, .pruning, .repotting, .note:
            return nil
        default:
            return nil
        }
    }
    
    func recordTypeCard(_ type: RecordType) -> some View {
        let isSelected = selectedType == type
        
        return VStack(alignment: .leading, spacing: 12) {
            Image(systemName: type.systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .green)
            
            Text(type.label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : .primary)
            
            Text(typeDescription(for: type))
                .font(.caption)
                .foregroundStyle(isSelected ? .white.opacity(0.82) : .secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    isSelected
                    ? LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [.white.opacity(0.82), .white.opacity(0.58)], startPoint: .top, endPoint: .bottom)
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(isSelected ? .clear : .white.opacity(0.55), lineWidth: 1)
        }
    }
    
    func amountCard(_ amount: RecordMetadata.WaterAmount) -> some View {
        let isSelected = waterAmount == amount
        
        return HStack {
            Text(amount.label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .primary)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isSelected ? Color.green : Color.green.opacity(0.10))
        )
    }
    
    func typeDescription(for type: RecordType) -> String {
        switch type {
        case .watering:
            "Log moisture and water amount."
        case .fertilizing:
            "Record nutrient feeding details."
        case .pestControl:
            "Track sprays and treatments."
        case .pruning:
            "Log trimming and cleanup work."
        case .repotting:
            "Track pot and soil changes."
        case .photo:
            "Save a visual progress update."
        case .note:
            "Capture a general care note."
        default:
            ""
        }
    }

    func typeHint(title: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AddCareRecordPage(plant: PreviewData.healthyPlant)
        .modelContainer(.preview)
}
