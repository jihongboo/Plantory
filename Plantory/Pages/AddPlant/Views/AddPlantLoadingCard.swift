import SwiftUI

struct AddPlantLoadingCard: View {
    var body: some View {
        CardView {
            HStack(spacing: 14) {
                ProgressView()

                Text("Analyzing your plant")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    AddPlantLoadingCard()
        .padding()
}
