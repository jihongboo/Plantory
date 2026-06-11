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
            .pixelNavigationTitle(title: "Add Log", subtitle: Text(verbatim: plant.displayName)) {
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
                Task {
                    await saveLog()
                }
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
    
    func saveLog() async {
        do {
            let trimmedNote = trimmed(note)
            let recordID = UUID()
            let photoID = recordImage == nil ? nil : UUID()
            let photoData = try recordImage.map {
                guard let data = ImageCompression.compressedJPEGData(from: $0) else {
                    throw AppError.custom(String(localized: "The photo data is broken."))
                }
                return data
            }

            if let photoData, let photoID {
                try PlantRecordPhotoStore.shared.savePhotoData(photoData, for: photoID)
            }

            let record = PlantRecord(
                id: recordID,
                createdAt: createdAt,
                note: trimmedNote,
                photoID: photoID,
                plant: plant
            )
            
            modelContext.insert(record)
            try modelContext.save()
            dismiss()

            if photoID != nil {
                Task { @MainActor in
                    do {
                        try await PlantRecordPhotoStore.shared.uploadPhoto(for: record)
                        try modelContext.save()
                    } catch {
                        // Keep the local log usable. A later sync pass can retry the upload.
                    }
                }
            }
        } catch {
            // show error alert
        }
    }
}
