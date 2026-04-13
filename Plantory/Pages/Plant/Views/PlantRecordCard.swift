import SwiftUI

struct PlantRecordCard: View {
    let record: PlantRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(record.type.label, systemImage: record.type.systemImage)
                .font(.headline)

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

            if let metadata = record.metadata {
                PlantRecordMetadataView(metadata: metadata, type: record.type)
            }
        }
    }
}

private struct PlantRecordMetadataView: View {
    let metadata: RecordMetadata
    let type: RecordType

    @ViewBuilder
    var body: some View {
        if let result = metadata.diagnosis?.result {
            VStack(alignment: .leading, spacing: 6) {
                Text("Diagnosis: \(result.problem)")
                if let firstSuggestion = result.suggestions.first {
                    Text("Suggestion: \(firstSuggestion)")
                }
            }
        }

        switch type {
        case .watering:
            if let amountLabel = metadata.watering?.amountLabel {
                Text("Amount: \(amountLabel)")
            }
        case .fertilizing:
            if let fertilizerName = metadata.fertilizing?.name {
                Text("Fertilizer: \(fertilizerName)")
            }
            if let dilution = metadata.fertilizing?.dilution {
                Text("Dilution: \(dilution)")
            }
        case .pestControl:
            if let pesticideName = metadata.pestControl?.productName {
                Text("Product: \(pesticideName)")
            }
            if let pestNotes = metadata.pestControl?.treatmentNotes {
                Text("Treatment: \(pestNotes)")
            }
        case .photo, .pruning, .repotting, .note:
            EmptyView()
        }
    }
}
