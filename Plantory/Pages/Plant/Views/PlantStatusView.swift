import SwiftUI

struct PlantStatusView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(plant.healthStatus.label, systemImage: plant.healthStatus.systemImage)
                .font(.headline)

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
