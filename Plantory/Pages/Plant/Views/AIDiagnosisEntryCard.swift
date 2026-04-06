import SwiftUI

struct AIDiagnosisEntryCard: View {
    let onImagePicked: (PlatformImage) -> Void

    @State private var isPresentingCamera = false
    @State private var isPresentingPhotoLibrary = false
    @State private var pickedImage: PlatformImage?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.39, blue: 0.23),
                            Color(red: 0.36, green: 0.67, blue: 0.42),
                            Color(red: 0.80, green: 0.92, blue: 0.69)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.18))
                        .padding(20)
                }

            VStack(alignment: .leading, spacing: 14) {
                Label("AI Diagnosis", systemImage: "stethoscope")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                Text("Snap a leaf photo or use one from your library to get a quick health read, likely causes, and next-step suggestions.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))

                Menu {
                    Button {
                        isPresentingCamera = true
                    } label: {
                        Label("Take Photo", systemImage: "camera.fill")
                    }

                    Button {
                        isPresentingPhotoLibrary = true
                    } label: {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Label("Start Diagnosis", systemImage: "sparkles.rectangle.stack.fill")
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(.regularMaterial, in: Capsule())
                        .foregroundStyle(.primary)
                }
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 186)
        .glassEffect(in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 18, y: 12)
        .cameraPicker(isPresented: $isPresentingCamera, image: pickedImageBinding)
        .plantPhotoPicker(isPresented: $isPresentingPhotoLibrary, image: pickedImageBinding)
    }

    private var pickedImageBinding: Binding<PlatformImage?> {
        Binding(
            get: { pickedImage },
            set: { newValue in
                pickedImage = newValue
                guard let newValue else { return }
                onImagePicked(newValue)
                pickedImage = nil
            }
        )
    }
}
