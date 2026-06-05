import SwiftUI

struct CareTileView: View {
    let title: LocalizedStringKey
    let icon: String
    let indicator: CareTileIndicator
    let tint: Color
    let usesFixedHeight: Bool
    let detail: String

    init(
        title: LocalizedStringKey,
        icon: String,
        indicator: CareTileIndicator = .none,
        tint: Color,
        usesFixedHeight: Bool = true,
        detail: String
    ) {
        self.title = title
        self.icon = icon
        self.indicator = indicator
        self.tint = tint
        self.usesFixedHeight = usesFixedHeight
        self.detail = detail
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            indicatorView

            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(minHeight: usesFixedHeight ? 150 : nil, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

}

private extension CareTileView {
    @ViewBuilder
    var indicatorView: some View {
        switch indicator {
        case let .level(level):
            LevelMeterView(level: level, tint: tint)
        case let .temperature(activeBands):
            TemperatureMeterView(activeBands: activeBands)
        case .none:
            EmptyView()
        }
    }
}
