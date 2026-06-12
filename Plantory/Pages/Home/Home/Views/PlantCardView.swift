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
        if let photoData = plant.photoData,
           let image = Image(data: photoData) {
            image
                .resizable()
                .scaledToFit()
        } else {
            plantInformationImage
        }
    }

    var plantInformationImage: some View {
        AsyncImage(url: plant.plantInformation?.imageURL) { phase in
            if case let .success(image) = phase {
                image
                    .pixelate()
                    .resizable()
                    .scaledToFit()
            } else {
                defaultPlantImage
            }
        }
    }

    var defaultPlantImage: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(.white.opacity(0.8))
            .padding(18)
    }
}
