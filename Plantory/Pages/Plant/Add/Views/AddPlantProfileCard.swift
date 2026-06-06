import SwiftUI

struct AddPlantProfileCard: View {
    let info: PlantInformation
    let image: Image?

    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground, padding: 24) {
            HStack(spacing: 16) {
                plantImage
                    .frame(width: 88, height: 88)

                VStack(alignment: .leading, spacing: 0) {
                    Text(info.displayCommonName)
                        .font(.pixel(.largeTitle))
                        .foregroundStyle(.white)
                        .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(info.species)
                        .font(.pixel(.title3))
                        .foregroundStyle(.pixelCream)
                        .shadow(color: .pixelInk.opacity(0.8), radius: 0, x: 1, y: 1)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
    }
}

#Preview {
    AddPlantProfileCard(info: .monstera, image: nil)
        .padding()
        .background(.pixelPaper)
}

private extension AddPlantProfileCard {
    @ViewBuilder
    var plantImage: some View {
        PixelRectangleCard {
            if let image {
                image
                    .pixelate()
                    .resizable()
                    .scaledToFit()
            } else {
                Image("PixelMonsteraHealthy")
                    .pixelate()
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
