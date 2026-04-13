import SwiftData
import SwiftUI

struct PlantInformationPage: View {
    let info: PlantInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PlantInfoInformationCard(info: info)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(info.commonName)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var plantImage: some View {
        if let assetImage = catalogImage {
            assetImage
                .resizable()
                .scaledToFit()
                .padding(28)
                .background(
                    LinearGradient(
                        colors: [
                            Color.green.opacity(0.14),
                            Color.mint.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else if let photoURL = info.photoURL,
                  let url = URL(string: photoURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure, .empty:
                    fallbackArtwork
                @unknown default:
                    fallbackArtwork
                }
            }
        } else {
            fallbackArtwork
        }
    }

    private var catalogImage: Image? {
        if let speciesData = PlatformImageData.named(info.species),
           let image = Image(data: speciesData) {
            return image
        }

        if let commonNameData = PlatformImageData.named(info.commonName),
           let image = Image(data: commonNameData) {
            return image
        }

        return nil
    }

    private var fallbackArtwork: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 78, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                )

            Text(info.commonName)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.10),
                    Color.mint.opacity(0.06),
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(info: PreviewData.healthyPlant.information!)
    }
    .modelContainer(.preview)
}
