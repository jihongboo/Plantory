import SwiftUI

struct PlantRecordCard: View {
    let record: PlantRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(record.type.label, systemImage: record.type.systemImage)
                .font(.headline)
                .foregroundStyle(record.type.themeColor)

            Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundStyle(.tertiary)

            if !record.note.isEmpty {
                Text(record.note)
                    .foregroundStyle(.primary)
            }

            if let photoData = record.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }

            if let result = record.diagnosis?.result {
                PlantRecordDiagnosisView(result: result)
            }
        }
    }
}

private struct PlantRecordDiagnosisView: View {
    let result: DiagnosisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Diagnosis", systemImage: "stethoscope")
                .font(.headline)
                .foregroundStyle(.green)
            Text(result.problem)
                .font(.headline)
                .foregroundStyle(.primary)

            PlantRecordDiagnosisTag(
                title: "Possible Cause",
                systemImage: "exclamationmark.triangle.fill",
                contents: result.causes,
                tint: .orange
            )

            PlantRecordDiagnosisTag(
                title: "Suggestion",
                systemImage: "leaf.fill",
                contents: result.suggestions,
                tint: .green
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PlantRecordDiagnosisTag: View {
    let title: String
    let systemImage: String
    let contents: [String]
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(tint)

            ForEach(contents, id: \.self) { content in
                Text(content)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(tint.opacity(0.12))
        }
    }
}
#Preview("Action Record") {
    CardView {
        PlantRecordCard(
            record: PlantRecord(
                actionType: .watering,
                createdAt: .now.addingTimeInterval(-86_400)
            )
        )
    }
    .padding()
}

#Preview("Diagnosis Record") {
    CardView {
        PlantRecordCard(
            record: PlantRecord(
                createdAt: .now.addingTimeInterval(-3 * 86_400),
                note: "Checked yellowing on older leaves near the edge.",
                photoData: PlatformImageData.named("Monstera deliciosa"),
                diagnosis: DiagnosisMetadata(
                    result: DiagnosisResult(
                        species: "Monstera deliciosa",
                        problem: "Mild overwatering stress",
                        causes: ["Soil stayed damp for too long"],
                        suggestions: ["Wait for the top soil to dry before watering again"],
                        rawResponse: ""
                    )
                )
            )
        )
    }
    .padding()
}
