import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        PixelRoundedRectangleCard {
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
                        .font(.pixel(.title2))
                        .foregroundStyle(Color(.pixelInk))
                        .lineLimit(1)
                    
                    Text(plant.information?.commonName ?? "Houseplant")
                        .font(.pixel(.callout))
                        .foregroundStyle(Color(.pixelInk).opacity(0.64))
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

}

#Preview {
    HStack {
        PlantCardView(plant: {
            let p = Plant(nickname: "My Monstera", imageData: PlatformImageData.monstera, information: .init(species: "", commonName: "Plant", light: "", water: "", temperature: "", fertilizer: "", tips: ""))
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

private extension PlantCardView {
    @ViewBuilder
    var plantPhoto: some View {
        ZStack {
            if let photoData = plant.photoData,
               let image = Image(data: photoData) {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Image(fallbackSpriteName)
                    .pixelate()
                    .resizable()
                    .scaledToFit()
            }
        }
    }

    var fallbackSpriteName: String {
        switch plant.healthStatus {
        case .healthy:
            "PixelMonsteraHealthy"
        case .warning, .critical:
            "PixelSucculentWarning"
        }
    }

    func statusColor(for status: HealthStatus) -> Color {
        switch status {
        case .healthy: .green
        case .warning: .orange
        case .critical: .red
        }
    }
}
