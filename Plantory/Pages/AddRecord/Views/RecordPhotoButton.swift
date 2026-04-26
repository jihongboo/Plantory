import SwiftUI
import UIKit

struct RecordPhotoButton: View {
    @Binding var image: PlatformImage?

    @State private var showCameraPicker = false
    @State private var showRemovePhotoConfirmation = false
    @State private var pendingSourceImage: PlatformImage?
    @State private var pendingCropItem: ImageCropperItem?

    var body: some View {
        Button(action: handleTap) {
            photoPreview
        }
        .buttonStyle(.plain)
        .accessibilityLabel(image == nil ? "Add photo" : "Remove photo")
        .confirmationDialog("Remove Photo?", isPresented: $showRemovePhotoConfirmation, titleVisibility: .visible) {
            Button("Remove Photo", role: .destructive) {
                image = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the attached photo from the record.")
        }
        .cameraPicker(isPresented: $showCameraPicker, image: $pendingSourceImage)
        .onChange(of: pendingSourceImage) {
            guard let pendingSourceImage else { return }
            pendingCropItem = ImageCropperItem(image: pendingSourceImage)
            self.pendingSourceImage = nil
        }
        .imageCropper(item: $pendingCropItem) { croppedImage in
            image = croppedImage
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        if let selectedImage {
            selectedImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.green.opacity(0.08))
                .overlay {
                    VStack(spacing: 10) {
                        Image(systemName: "camera.on.rectangle")
                            .font(.system(size: 28))
                            .foregroundStyle(.green)

                        Text("No photo attached")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("Tap to add")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
        }
    }

    private var selectedImage: Image? {
        guard let image else { return nil }
        return Image(uiImage: image)
    }

    private func handleTap() {
        if image == nil {
            showCameraPicker = true
        } else {
            showRemovePhotoConfirmation = true
        }
    }
}
