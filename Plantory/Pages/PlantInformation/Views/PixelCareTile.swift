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

                indicatorView

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
        detail: PlantInformation.monstera.light
    )
    .padding()
    .background(.pixelPaper)
}

private extension PixelCareTile {
    @ViewBuilder
    var indicatorView: some View {
        switch indicator {
        case let .level(level):
            PixelProgressMeter(
                value: level,
                style: .fixed,
                accessibilityLabel: "Level \(level) of 3"
            )
        case let .temperature(activeBands):
            PixelProgressMeter(
                activeSegments: activeBands.pixelMeterSegments,
                style: .colorful,
                accessibilityLabel: "Temperature range"
            )
        }
    }
}

private extension Set where Element == TemperatureBand {
    var pixelMeterSegments: Set<Int> {
        Swift.Set<Int>(self.map { $0.rawValue + 1 })
    }
}
