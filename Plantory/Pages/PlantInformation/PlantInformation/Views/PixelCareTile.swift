import SwiftUI

struct PixelCareTile: View {
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    let indicator: PixelCareIndicator
    let detail: String

    var body: some View {
        PixelRectangleCard(fill: .pixelCream) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.black))
                        .foregroundStyle(tint)
                        .frame(width: 22)

                    Text(title)
                        .font(.pixel(.headline))
                        .foregroundStyle(.pixelInk)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                PixelProgressMeter(indicator: indicator)

                Text(detail)
                    .font(.pixel(.body))
                    .foregroundStyle(.pixelInk.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
            .frame(minHeight: 100, alignment: .topLeading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}

#Preview {
    PixelCareTile(
        title: "Light",
        systemImage: "sun.max.fill",
        tint: .pixelSun,
        indicator: .level(2),
        detail: PlantInformation.monstera.lightDetail
    )
    .padding()
    .background(.pixelPaper)
}
