import SwiftUI
import SwiftData

struct PlantInformationPage: View {
    let info: PlantInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                heroSection
                overviewCard
                careSection
                if !info.tips.isEmpty {
                    tipsCard
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(info.commonName)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                colors: [
                    Color.green.opacity(0.10),
                    Color.mint.opacity(0.06),
                    Color.clear
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            plantImage
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .background(
                    LinearGradient(
                        colors: [.green.opacity(0.16), .mint.opacity(0.08), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text(info.commonName)
                    .font(.largeTitle.bold())

                Text(info.species)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            }
        }
    }

    private var overviewCard: some View {
        informationCard(title: "About", systemImage: "text.book.closed") {
            Text(info.displayOverview)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Care Guide")
                .font(.title3.weight(.semibold))

            informationCard(title: "Light", systemImage: "sun.max.fill") {
                Text(info.light)
            }

            informationCard(title: "Water", systemImage: "drop.fill") {
                Text(info.water)
            }

            informationCard(title: "Temperature", systemImage: "thermometer.medium") {
                Text(info.temperature)
            }

            informationCard(title: "Fertilizer", systemImage: "leaf.circle.fill") {
                Text(info.fertilizer)
            }
        }
    }

    private var tipsCard: some View {
        informationCard(title: "Tips", systemImage: "sparkles") {
            Text(info.tips)
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var plantImage: some View {
        if let assetImage = catalogImage {
            assetImage
                .resizable()
                .scaledToFit()
                .padding(24)
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
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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
        VStack(spacing: 14) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 72))
                .foregroundStyle(
                    LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom)
                )

            Text(info.commonName)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func informationCard<Content: View>(
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .foregroundStyle(.primary)

            content()
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.3), lineWidth: 1)
        }
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(info: PreviewData.healthyPlant.information!)
    }
    .modelContainer(.preview)
}
