import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        PixelPanel(padding: 10) {
            VStack(alignment: .leading, spacing: 10) {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(PixelTheme.cream)
                        .frame(height: 132)
                        .overlay {
                            plantPhoto
                                .padding(8)
                        }
                        .overlay {
                            Rectangle()
                                .stroke(PixelTheme.paperShadow.opacity(0.55), lineWidth: 2)
                        }

                    Image(systemName: plant.healthStatus.systemImage)
                        .font(.headline.weight(.black))
                        .foregroundStyle(statusColor(for: plant.healthStatus))
                        .padding(7)
                        .background(PixelTheme.paper, in: .rect(cornerRadius: 3))
                        .overlay {
                            Rectangle()
                                .stroke(PixelTheme.paperShadow, lineWidth: 1.5)
                        }
                        .padding(8)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(plant.displayName)
                        .font(.headline.weight(.black))
                        .foregroundStyle(PixelTheme.ink)
                        .lineLimit(1)
                    
                    Text(plant.information?.commonName ?? "Houseplant")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PixelTheme.ink.opacity(0.64))
                        .lineLimit(1)

                    PixelStatusBadge(status: plant.healthStatus)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var plantPhoto: some View {
        ZStack {
            if let photoData = plant.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(.rect(cornerRadius: 4))
            } else {
                Image(fallbackSpriteName)
                    .pixelArt()
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    private var fallbackSpriteName: String {
        switch plant.healthStatus {
        case .healthy:
            "PixelMonsteraHealthy"
        case .warning, .critical:
            "PixelSucculentWarning"
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
            let p = Plant(nickname: "My Monstera", imageData: PlatformImageData.named("Monstera deliciosa"), information: .init(species: "", commonName: "Plant", light: "", water: "", temperature: "", fertilizer: "", tips: ""))
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
