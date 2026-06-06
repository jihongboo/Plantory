import SwiftUI

struct AddPlantNameCard: View {
    @Binding var nickname: String
    @FocusState private var isFocused: Bool

    var body: some View {
        PixelRoundedRectangleCard(
            title: "Name Your Plant",
            systemImage: "pencil"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                PixelTextField(
                    prompt: "Example: Living room monstera",
                    text: $nickname
                )
                .focused($isFocused)
            }
        }
        .onAppear {
            isFocused = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

#Preview {
    @Previewable @State var nickname = ""

    AddPlantNameCard(nickname: $nickname)
        .padding()
        .background(.pixelPaper)
}
