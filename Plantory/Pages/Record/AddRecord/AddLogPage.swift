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
                        Text("Notes(Optional)")
                            .font(.headline)
                        
                        TextField("Write something about this plant", text: $note, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
            }
            .navigationTitle("Add Log")
            .navigationBarTitleDisplayMode(.inline)
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
                    .disabled(recordImage == nil)
                }
            }
        }
    }
}

private extension AddLogPage {
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func saveLog() {
        guard let recordImage else { return }

        do {
            let trimmedNote = trimmed(note)
            let photoData = try ImageCompression.compressedPNGData(from: recordImage)

            let record = PlantRecord(
                createdAt: createdAt,
                note: trimmedNote,
                photoData: photoData,
                plant: plant
            )
            
            modelContext.insert(record)
            try modelContext.save()
            dismiss()
        } catch {
            // show error alert
        }
    }
}

#Preview {
    AddLogPage(plant: .monstera)
        .modelContainer(.preview)
}
