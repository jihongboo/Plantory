import SwiftUI

struct AddPlantPhotoHeroCard: View {
    let image: Image?
    let displayName: String?
    @Binding var nickname: String
    @FocusState private var nicknameFieldFocused: Bool
    @State private var isRenaming = false

    var body: some View {
        CardView {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)

                if let image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.3)],
                                startPoint: .center,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Spacer()

                    HStack(alignment: .bottom, spacing: 12) {
                        Text(displayName ?? "Analyzing photo")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)

                        Spacer(minLength: 8)

                        Button(isRenaming ? "Done" : "Rename") {
                            isRenaming.toggle()
                            nicknameFieldFocused = isRenaming
                        }
                        .buttonStyle(.glass)
                        .font(.subheadline.weight(.semibold))
                    }

                    if isRenaming {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Plant Name")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.88))

                            TextField("Nickname", text: $nickname)
                                .textFieldStyle(.plain)
                                .focused($nicknameFieldFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    isRenaming = false
                                    nicknameFieldFocused = false
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 14)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .padding(18)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fit)
        }
        .animation(.snappy(duration: 0.24), value: isRenaming)
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    @Previewable @State var nickname = "Living Room Monstera"

    AddPlantPhotoHeroCard(
        image: AddPlantCardPreviewSupport.image,
        displayName: nickname,
        nickname: $nickname
    )
    .padding()
}
