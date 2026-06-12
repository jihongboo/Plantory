import SwiftUI

struct PlantInformationHeader: View {
    let info: PlantInformation

    var body: some View {
        PixelRoundedRectangleCard(fill: .buttonBackground, padding: 24) {
            VStack(alignment: .leading, spacing: 14) {
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

                PixelDashedDivider(
                    color: .pixelCream.opacity(0.7),
                    lineWidth: 3
                )

                HStack(spacing: 10) {
                    PixelHeroBadge(title: "Light", value: info.lightLevel.capitalized)
                    PixelHeroBadge(title: "Water", value: info.waterLevel.capitalized)
                    PixelHeroBadge(title: "Care", value: info.careDifficulty.capitalized)
                }
            }
        }
    }
}

#Preview {
    PlantInformationHeader(info: .monstera)
        .padding()
        .background(.pixelPaper)
}

private extension PlantInformationHeader {
    @ViewBuilder
    var plantImage: some View {
        PixelRectangleCard {
            AsyncImage(url: info.imageURL) { phase in
                if case let .success(image) = phase {
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
}
