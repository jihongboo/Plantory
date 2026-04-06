import SwiftUI
import SwiftData

struct AddLogPage: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let plant: Plant
    
    @State private var createdAt: Date = .now
    @State private var note = ""
    @State private var recordImage: PlatformImage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    RecordPhotoButton(image: $recordImage)
                        .aspectRatio(1.8, contentMode: .fit)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                
                Section("Log Detail") {
                    DatePicker("Time", selection: $createdAt)
                        .font(.headline)
                    
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextField("Write something about this plant", text: $note, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
            }
            .navigationTitle("Add Log")
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
                        saveLog()
                    }
                    .bold()
                    .disabled(!canSave)
                }
            }
        }
    }
}

private extension AddLogPage {
    var canSave: Bool {
        compressedPhotoData != nil || !trimmed(note).isEmpty
    }
    
    var compressedPhotoData: Data? {
        guard let recordImage else { return nil }
        return ImageCompression.compressedJPEGData(from: recordImage)
    }
    
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func saveLog() {
        let trimmedNote = trimmed(note)
        let photoData = compressedPhotoData
        let type: RecordType = photoData == nil ? .note : .photo
        
        let record = PlantRecord(
            type: type,
            createdAt: createdAt,
            note: trimmedNote,
            photoData: photoData,
            plant: plant
        )
        
        modelContext.insert(record)
        dismiss()
    }
}

#Preview {
    AddLogPage(plant: PreviewData.healthyPlant)
        .modelContainer(.preview)
}
