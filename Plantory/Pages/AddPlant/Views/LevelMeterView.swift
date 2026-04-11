import SwiftUI

struct LevelMeterView: View {
    let level: Int
    let tint: Color

    var body: some View {
        HStack(spacing: 5) {
            ForEach(1 ... 3, id: \.self) { index in
                Capsule()
                    .fill(fillColor(for: index))
                    .frame(height: 7)
            }
        }
    }

    private func fillColor(for index: Int) -> Color {
        guard index <= level else {
            return Color.secondary.opacity(0.14)
        }

        return tint.opacity(index == level ? 0.95 : 0.72)
    }
}
