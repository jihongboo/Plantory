import SwiftData
import SwiftUI

struct PlantInformationPage: View {
    let info: PlantInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                PlantInfoInformationCard(info: info)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(info.commonName)
        .navigationBarTitleDisplayMode(.inline)
        .background(pageBackground)
    }

    private var pageBackground: some View {
        LinearGradient(
            colors: [
                Color(.systemGroupedBackground),
                Color.green.opacity(0.05),
                Color.mint.opacity(0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var heroSection: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(.white.opacity(0.55), lineWidth: 1)
                }

            plantImage
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .overlay(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.22)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                }

            VStack(alignment: .leading, spacing: 10) {
                Text(info.commonName)
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.white)

                Text(info.species)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.86))
                    .italic()

                if !info.displayOverview.isEmpty {
                    Text(info.displayOverview)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.92))
                        .lineLimit(3)
                }
            }
            .padding(22)
        }
        .frame(height: 300)
        .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
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
