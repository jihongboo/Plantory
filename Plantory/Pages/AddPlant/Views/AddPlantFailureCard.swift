import SwiftUI

struct AddPlantFailureCard: View {
    let recognitionResult: DoubaoPlantRecognitionService.IdentificationResult?
    let errorMessage: String?

    var body: some View {
        CardView(
            titleKey:"Recognition Result",
            subtitleKey: "The photo was processed, but AI could not build a complete plant profile.",
            systemImage: "exclamationmark.triangle.fill",
            iconTint: .orange
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if let recognitionResult {
                    Text(recognitionResult.structuredResult.summary)
                        .font(.headline)

                    Text(recognitionResult.structuredResult.overview)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(errorMessage ?? "Could not identify the plant from this photo.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    AddPlantFailureCard(
        recognitionResult: AddPlantCardPreviewSupport.recognition,
        errorMessage: "AI could not identify a complete plant profile from this photo."
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
