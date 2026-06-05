import SwiftUI

struct PixelHeroBadge: View {
    let title: LocalizedStringKey
    let value: String

    var body: some View {
        PixelRectangleCard(fill: .pixelLeafDark) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.pixel(.headline))
                    .foregroundStyle(.pixelCream.opacity(0.86))

                Text(value)
                    .font(.pixel(.body))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
    }
}

#Preview {
    PixelHeroBadge(title: "Care", value: "Moderate")
        .padding()
        .background(Color(.buttonBackground))
}
