import SwiftUI

struct PlantStatusView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: plant.healthStatus.systemImage)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(statusColor(for: plant.healthStatus))
                    .overlay {
                        Rectangle()
                            .stroke(PixelTheme.ink.opacity(0.62), lineWidth: 2)
                    }

                Text(plant.healthStatus.label)
                    .font(PixelTheme.font(size: 24, weight: .bold, relativeTo: .title3))
                    .foregroundStyle(PixelTheme.ink)

                Spacer()
            }

            if plant.activeIssues.isEmpty {
                Text("No active issues right now. Keep following the regular care routine.")
                    .font(PixelTheme.font(size: 17, relativeTo: .body))
                    .foregroundStyle(PixelTheme.ink.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(PixelTheme.cream, in: .rect(cornerRadius: 4))
                    .overlay {
                        Rectangle()
                            .stroke(PixelTheme.paperShadow.opacity(0.55), lineWidth: 2)
                    }
            } else {
                ForEach(plant.activeIssues) { issue in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: issue.type.systemImage)
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(statusColor(for: plant.healthStatus))
                            .overlay {
                                Rectangle()
                                    .stroke(PixelTheme.ink.opacity(0.55), lineWidth: 2)
                            }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(issue.type.label)
                                .font(PixelTheme.font(size: 18, weight: .bold, relativeTo: .subheadline))
                                .foregroundStyle(PixelTheme.ink)

                            Text(issue.severity.label)
                                .font(PixelTheme.font(size: 14, weight: .bold, relativeTo: .caption))
                                .foregroundStyle(statusColor(for: plant.healthStatus))

                            if !issue.note.isEmpty {
                                Text(issue.note)
                                    .font(PixelTheme.font(size: 15, relativeTo: .footnote))
                                    .foregroundStyle(PixelTheme.ink.opacity(0.68))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(10)
                    .background(PixelTheme.cream, in: .rect(cornerRadius: 4))
                    .overlay {
                        Rectangle()
                            .stroke(PixelTheme.paperShadow.opacity(0.55), lineWidth: 2)
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
