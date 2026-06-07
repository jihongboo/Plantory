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
        PixelPage {
            ScrollView {
                LazyVStack(spacing: 16) {
                    PixelRoundedRectangleCard(
                        title: "Record Photo",
                        systemImage: "camera.fill"
                    ) {
                        RecordPhotoButton(image: $recordImage)
                            .aspectRatio(1.8, contentMode: .fit)
                    }
                                        
                    AddLogDetailsCard(
                        createdAt: $createdAt,
                        note: $note
                    )
                }
            }
            .pixelNavigationTitle(title: "Add Log", subtitle: plant.displayName) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 16, height: 16)
                }
            }
        }
        .pixelBottomActionBar {
            Button("Save Log", systemImage: "checkmark") {
                saveLog()
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        }
    }
}

#Preview {
    AddLogPage(plant: .monstera)
        .modelContainer(.preview)
}

private extension AddLogPage {
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func saveLog() {
        do {
            let trimmedNote = trimmed(note)
            let photoData = try recordImage.map {
                try ImageCompression.compressedPNGData(from: $0)
            }

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
