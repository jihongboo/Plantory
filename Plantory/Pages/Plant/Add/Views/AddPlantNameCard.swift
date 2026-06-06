import SwiftUI

struct AddPlantNameCard: View {
    @Binding var nickname: String
    @Binding var note: String
    @FocusState private var isFocused: Bool

    var body: some View {
        PixelRoundedRectangleCard(
            title: "Name Your Plant",
            systemImage: "pencil"
        ) {
            VStack(alignment: .leading, spacing: 14) {
                PixelTextField(
                    "Nickname",
                    prompt: "Example: Living room monstera",
                    text: $nickname
                )
                .focused($isFocused)

                PixelTextField(
                    "Notes(Optional)",
                    prompt: "Optional care notes",
                    text: $note,
                    axis: .vertical
                )
            }
        }
        .onAppear {
            isFocused = nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}

#Preview {
    @Previewable @State var nickname = ""
    @Previewable @State var note = ""

    AddPlantNameCard(nickname: $nickname, note: $note)
        .padding()
        .background(.pixelPaper)
}
