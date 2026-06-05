import SwiftUI

struct TemperatureMeterView: View {
    let activeBands: Set<TemperatureBand>

    var body: some View {
        HStack(spacing: 5) {
            ForEach(TemperatureBand.allCases, id: \.self) { band in
                Capsule()
                    .fill(fillColor(for: band))
                    .frame(height: 7)
            }
        }
        .padding(.vertical, 2)
    }

}

private extension TemperatureMeterView {
    func fillColor(for band: TemperatureBand) -> Color {
        guard activeBands.contains(band) else {
            return Color.secondary.opacity(0.14)
        }

        switch band {
        case .cool:
            return .blue.opacity(0.85)
        case .moderate:
            return .green.opacity(0.82)
        case .warm:
            return .red.opacity(0.82)
        }
    }
}
