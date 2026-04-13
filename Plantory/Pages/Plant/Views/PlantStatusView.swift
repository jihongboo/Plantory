import SwiftUI

struct PlantStatusView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(plant.healthStatus.label, systemImage: plant.healthStatus.systemImage)
                .font(.headline)
                .foregroundStyle(plant.healthStatus.themeColor)

            if plant.activeIssues.isEmpty {
                Text("No active issues right now. Keep following the regular care routine.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(plant.activeIssues) { issue in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: issue.type.systemImage)
                            .foregroundStyle(statusColor(for: plant.healthStatus))
                            .frame(width: 18)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(issue.type.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)

                            Text(issue.severity.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            if !issue.note.isEmpty {
                                Text(issue.note)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statusColor(for status: HealthStatus) -> Color {
        switch status {
        case .healthy:
            .green
        case .warning:
            .orange
        case .critical:
            .red
        }
    }
}
#Preview("Healthy") {
    let info = PlantInformation(
        species: "Epipremnum aureum",
        commonName: "Golden Pothos",
        light: "Bright indirect light",
        water: "Water when top soil dries",
        temperature: "18-30C",
        fertilizer: "Monthly in growing season",
        tips: "Trim long vines for fuller growth"
    )
    let plant = Plant(nickname: "Living Room Pothos", information: info)

    return PlantStatusView(plant: plant)
        .padding()
}

#Preview("Needs Attention") {
    let info = PlantInformation(
        species: "Monstera deliciosa",
        commonName: "Monstera",
        light: "Bright indirect light",
        water: "Every 7-10 days",
        temperature: "18-30C",
        fertilizer: "Monthly",
        tips: "Ensure good drainage"
    )
    let plant = Plant(nickname: "Corner Monstera", information: info)
    plant.activeIssues = [
        PlantIssue(
            type: .overwatered,
            severity: .moderate,
            note: "Top soil stays wet for more than 3 days."
        ),
        PlantIssue(
            type: .fungalDisease,
            severity: .mild,
            note: "Small spots observed on older leaves."
        )
    ]

    return PlantStatusView(plant: plant)
        .padding()
}

