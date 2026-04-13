import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            plantPhoto
                .frame(height: 150)

            VStack(alignment: .leading, spacing: 4) {
                Text(plant.displayName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)

                Label(plant.healthStatus.label, systemImage: plant.healthStatus.systemImage)
                    .font(.caption)
                    .foregroundStyle(statusColor(for: plant.healthStatus))
                    .labelIconToTitleSpacing(4)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }

    @ViewBuilder
    private var plantPhoto: some View {
        ZStack {
            LinearGradient(
                colors: [.primary.opacity(0.08), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
            
            if let photoData = plant.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        }
    }

    private func statusColor(for status: HealthStatus) -> Color {
        switch status {
        case .healthy: .green
        case .warning: .orange
        case .critical: .red
        }
    }
}

#Preview {
    HStack {
        PlantCardView(plant: {
            let p = Plant(nickname: "My Monstera", imageData: PlatformImageData.named("Monstera deliciosa"))
            return p
        }())

        PlantCardView(plant: {
            let p = Plant()
            p.activeIssues = [PlantIssue(type: .underwatered, severity: .moderate)]
            return p
        }())
    }
    .padding()
}
