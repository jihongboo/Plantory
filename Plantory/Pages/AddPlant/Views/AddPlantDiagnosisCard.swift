import SwiftUI

struct AddPlantDiagnosisCard: View {
    let state: AddPlantDiagnosisState
    let retryAction: () -> Void

    var body: some View {
        CardView(
            title: "Health Check",
            subtitle: "A first-pass diagnosis from the same imported photo.",
            systemImage: "stethoscope",
            iconTint: .orange
        ) {
            switch state {
            case .idle:
                Label("Diagnosis starts automatically after the photo is imported.", systemImage: "sparkles")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

            case .analyzing:
                HStack(spacing: 14) {
                    ProgressView()
                        .controlSize(.large)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Analyzing plant health")
                            .font(.headline)
                        Text("Checking the photo for watering stress, pests, disease, and other visible issues.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 6)

            case .failed(let message):
                VStack(alignment: .leading, spacing: 12) {
                    Label(message, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)

                    Button("Retry Diagnosis", action: retryAction)
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                }

            case .complete(let report):
                VStack(alignment: .leading, spacing: 14) {
                    HStack(spacing: 12) {
                        AddPlantRecognitionStatView(title: "Result", value: report.healthStatus.label)
                        AddPlantRecognitionStatView(title: "Confidence", value: "\(report.confidence)%")
                    }

                    Text(report.title)
                        .font(.headline)

                    Text(report.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let firstAction = report.carePlan.first {
                        Label("Next step: \(firstAction.title)", systemImage: "checkmark.circle")
                            .font(.subheadline.weight(.medium))
                    }
                }
            }
        }
    }
}

#Preview("Idle") {
    AddPlantDiagnosisCard(state: .idle, retryAction: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Analyzing") {
    AddPlantDiagnosisCard(state: .analyzing, retryAction: {})
        .padding()
        .background(Color(.systemGroupedBackground))
}

#Preview("Failed") {
    AddPlantDiagnosisCard(
        state: .failed("AI service timed out while checking the photo."),
        retryAction: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Complete") {
    AddPlantDiagnosisCard(
        state: .complete(AddPlantCardPreviewSupport.diagnosisReport),
        retryAction: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
