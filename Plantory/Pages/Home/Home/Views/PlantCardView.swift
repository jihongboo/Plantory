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
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(plant.displayName)
                        .font(.pixel(.title2))
                        .foregroundStyle(Color(.pixelInk))
                        .lineLimit(1)
                    
                    Text(plant.hasPlantInformation ? "Saved plant guide" : "Houseplant")
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
            let p = Plant(nickname: "My Monstera", imageData: PlatformImageData.monstera, information: .init(species: "", commonName: "Plant", temperature: "", tips: ""))
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
