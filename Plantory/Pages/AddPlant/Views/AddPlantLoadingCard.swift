import SwiftUI

struct AddPlantLoadingCard: View {
    var body: some View {
        CardView {
            PixelProgressView("Analyzing your plant", activeColor: .pixelSun)
                .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    AddPlantLoadingCard()
        .padding()
}
