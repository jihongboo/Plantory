import SwiftData
import SwiftUI

struct PlantInformationPage: View {
    let info: PlantInformation

    var body: some View {
        PixelPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    PixelNavigationBar(title: "Plant Info")

                    PixelPlantInformationHero(info: info)

                    PixelRoundedRectangleCard(
                        title: "Overview",
                        systemImage: "text.book.closed.fill"
                    ) {
                        Text(info.displayOverview)
                            .font(.pixel(.body))
                            .foregroundStyle(.pixelInk.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PixelRoundedRectangleCard(
                        title: "Care Tips",
                        systemImage: "sparkles"
                    ) {
                        Text(info.tips)
                            .font(.pixel(.body))
                            .foregroundStyle(.pixelInk.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    PixelRoundedRectangleCard(
                        title: "Care Guide",
                        systemImage: "leaf.fill"
                    ) {
                        PlantInformationCareGuide(info: info)
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(info: Plant.monstera.information!)
    }
    .modelContainer(.preview)
}
