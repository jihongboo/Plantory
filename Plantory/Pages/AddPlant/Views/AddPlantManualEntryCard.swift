import SwiftData
import SwiftUI

struct AddPlantManualEntryCard: View {
    @Binding var plantInformation: PlantInformation?

    var body: some View {
        CardView(
            titleKey: "Manual Entry",
            subtitleKey: "Search the plant manually when recognition is incomplete or incorrect.",
            systemImage: "square.and.pencil",
            iconTint: .blue
        ) {
            VStack(alignment: .leading, spacing: 12) {
                Text("If the photo result is not correct, enter the plant name manually and let AI generate the care profile.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                NavigationLink {
                    PlantSearchPage(selectedInfo: $plantInformation)
                } label: {
                    Label("Enter Plant Name", systemImage: "magnifyingglass")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
    }
}

#Preview {
    @Previewable @State var plantInformation: PlantInformation?

    NavigationStack {
        AddPlantManualEntryCard(plantInformation: $plantInformation)
            .padding()
            .background(Color(.systemGroupedBackground))
    }
    .modelContainer(.preview)
}
