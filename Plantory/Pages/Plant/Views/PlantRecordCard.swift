import SwiftUI

struct PlantRecordCard: View {
    let record: PlantRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: record.type.systemImage)
                    .font(.subheadline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(record.type.themeColor)
                    .overlay {
                        Rectangle()
                            .stroke(PixelTheme.ink.opacity(0.58), lineWidth: 2)
                    }

                VStack(alignment: .leading, spacing: 3) {
                    Text(record.type.label)
                        .font(PixelTheme.font(size: 20, weight: .bold, relativeTo: .headline))
                        .foregroundStyle(PixelTheme.ink)

                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(PixelTheme.font(size: 13, weight: .bold, relativeTo: .caption))
                        .foregroundStyle(PixelTheme.ink.opacity(0.54))
                }

                Spacer(minLength: 0)
            }

            if !record.note.isEmpty {
                Text(record.note)
                    .font(PixelTheme.font(size: 16, relativeTo: .body))
                    .foregroundStyle(PixelTheme.ink.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let photoData = record.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 180)
                    .padding(6)
                    .background(PixelTheme.cream)
                    .overlay {
                        Rectangle()
                            .stroke(PixelTheme.paperShadow.opacity(0.72), lineWidth: 2)
                    }
            }

            if let result = record.diagnosis?.result {
                PlantRecordDiagnosisView(result: result)
            }
        }
        .padding(.vertical, 12)
    }
}

private struct PlantRecordDiagnosisView: View {
    let result: DiagnosisResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Diagnosis", systemImage: "stethoscope")
                .font(PixelTheme.font(size: 19, weight: .bold, relativeTo: .headline))
                .foregroundStyle(PixelTheme.leaf)
            Text(result.problem)
                .font(PixelTheme.font(size: 17, weight: .bold, relativeTo: .subheadline))
                .foregroundStyle(PixelTheme.ink)
                .fixedSize(horizontal: false, vertical: true)

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
        .padding(10)
        .background(PixelTheme.cream, in: .rect(cornerRadius: 4))
        .overlay {
            Rectangle()
                .stroke(PixelTheme.paperShadow.opacity(0.55), lineWidth: 2)
        }
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
                .font(PixelTheme.font(size: 14, weight: .bold, relativeTo: .caption))
                .foregroundStyle(tint)

            ForEach(contents, id: \.self) { content in
                Text(content)
                    .font(PixelTheme.font(size: 15, relativeTo: .subheadline))
                    .foregroundStyle(PixelTheme.ink.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(tint.opacity(0.12), in: .rect(cornerRadius: 3))
        .overlay {
            Rectangle()
                .stroke(tint.opacity(0.36), lineWidth: 1.5)
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
