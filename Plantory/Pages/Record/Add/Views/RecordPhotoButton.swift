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

}

private extension RecordPhotoButton {
    @ViewBuilder
    var photoPreview: some View {
        if let selectedImage {
            PixelRectangleCard(fill: .pixelCream) {
                selectedImage
                    .pixelate()
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
        } else {
            PixelRectangleCard(fill: .pixelCream) {
                VStack(spacing: 10) {
                    Image(systemName: "camera.on.rectangle")
                        .font(.title2.weight(.black))
                        .foregroundStyle(.pixelLeaf)

                    Text("No photo attached")
                        .font(.pixel(.headline))
                        .foregroundStyle(.pixelInk)

                    Text("Tap to add")
                        .font(.pixel(.subheadline))
                        .foregroundStyle(Color.pixelInk.opacity(0.62))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    var selectedImage: Image? {
        guard let image else { return nil }
        return Image(uiImage: image)
    }

    func handleTap() {
        if image == nil {
            showCameraPicker = true
        } else {
            showRemovePhotoConfirmation = true
        }
    }
}
