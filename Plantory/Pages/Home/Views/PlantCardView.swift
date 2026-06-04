import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        PixelCard {
            VStack {
                ZStack(alignment: .topTrailing) {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 132)
                        .overlay {
                            plantPhoto
                        }

                    Image(systemName: plant.healthStatus.systemImage)
                        .font(.title.weight(.black))
                        .foregroundStyle(statusColor(for: plant.healthStatus))
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(plant.displayName)
                        .font(PixelTheme.font(size: 22, weight: .bold, relativeTo: .headline))
                        .foregroundStyle(PixelTheme.ink)
                        .lineLimit(1)
                    
                    Text(plant.information?.commonName ?? "Houseplant")
                        .font(PixelTheme.font(size: 16, weight: .semibold, relativeTo: .caption))
                        .foregroundStyle(PixelTheme.ink.opacity(0.64))
                        .lineLimit(1)
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
