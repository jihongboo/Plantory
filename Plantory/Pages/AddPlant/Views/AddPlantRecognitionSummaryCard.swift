import SwiftUI

struct AddPlantRecognitionSummaryCard: View {
    let result: DoubaoPlantRecognitionService.IdentificationResult

    var body: some View {
        CardView(
            title: "AI Recognition",
            subtitle: "Match & confidence from photo.",
            systemImage: "sparkles",
            iconTint: .teal
        ) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    AddPlantRecognitionStatView(
                        title: "Detected Name",
                        value: result.structuredResult.displayName ?? "Unknown"
                    )
                    AddPlantRecognitionStatView(
                        title: "Confidence",
                        value: "\(result.structuredResult.confidence)%"
                    )
                }

                Text(result.structuredResult.summary)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)

                Text(result.structuredResult.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    AddPlantRecognitionSummaryCard(result: AddPlantCardPreviewSupport.recognition)
        .padding()
}
