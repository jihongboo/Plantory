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
                        Color(.pixelInk).opacity(0.22),
                        Color(.pixelLeafDark).opacity(0.48)
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
