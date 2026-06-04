import SwiftUI

struct PageBackground: View {
    var body: some View {
        Image(.pixelHomeRoom)
            .pixelate()
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: [
                        .black.opacity(0.04),
                        PixelTheme.ink.opacity(0.22),
                        PixelTheme.leafDark.opacity(0.48)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}

#Preview {
    PageBackground()
}
