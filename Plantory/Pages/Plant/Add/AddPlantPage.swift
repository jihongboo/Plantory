import SwiftUI
import SwiftData

struct AddPlantPage: View {
    let plantInformation: PlantInformation
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var nickname = ""
    @State private var note = ""
    
    var body: some View {
        PixelPage {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        
                        AddPlantProfileCard(info: plantInformation, image: plantImage)
                        
                        AddPlantNameCard(nickname: $nickname, note: $note)
                        
                        PixelRoundedRectangleCard(
                            title: "Overview",
                            systemImage: "text.book.closed.fill"
                        ) {
                            Text(plantInformation.displayOverview)
                                .font(.pixel(.body))
                                .foregroundStyle(Color.pixelInk.opacity(0.78))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        PixelRoundedRectangleCard(
                            title: "Care Guide",
                            systemImage: "leaf.fill"
                        ) {
                            PlantInformationCareGuide(info: plantInformation)
                        }
                    }
                }
            }
            .pixelNavigationTitle(title: "Add Plant", subtitle: "Name your plant")
        }
        .pixelBottomActionBar {
            Button("Add to my garden", systemImage: "plus") {
                addPlant()
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            .disabled(nickname.isEmpty)
        }
    }
}

// MARK: - Preview

#Preview {
    AddPlantPage(plantInformation: .monstera)
        .modelContainer(.preview)
}

private extension AddPlantPage {
    var plantImage: Image? {
        guard let imageData = plantInformation.imageData else { return nil }
        return Image(data: imageData)
    }
    
    func addPlant() {
        let plant = Plant(
            nickname: nickname,
            imageData: plantInformation.imageData,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            information: plantInformation
        )
        modelContext.insert(plant)
        dismiss()
    }
}
