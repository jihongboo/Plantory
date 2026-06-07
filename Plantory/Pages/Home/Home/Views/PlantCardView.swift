import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground) {
            VStack {
                PixelRectangleCard {
                    Rectangle()
                        .fill(.clear)
                        .frame(height: 132)
                        .overlay {
                            plantPhoto
                        }
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(plant.displayName)
                        .font(.pixel(.title2))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(plant.plantInformation?.displayCommonName ?? "")
                        .font(.pixel(.callout))
                        .foregroundStyle(.white.secondary)
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
            let p = Plant(
                nickname: "My Monstera",
                imageData: PlatformImageData.monstera,
                information: .init(species: "", commonName: "Plant", temperature: "")
            )
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
                Image(.Plants.succulentHealthy)
                    .pixelate()
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
