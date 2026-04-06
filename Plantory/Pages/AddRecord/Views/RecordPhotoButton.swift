import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct RecordPhotoButton: View {
    @Binding var image: PlatformImage?

    @State private var showAddPhotoOptions = false
    @State private var showCameraPicker = false
    @State private var showPhotoPicker = false
    @State private var showRemovePhotoConfirmation = false

    var body: some View {
        Button(action: handleTap) {
            photoPreview
        }
        .buttonStyle(.plain)
        .accessibilityLabel(image == nil ? "Add photo" : "Remove photo")
        .confirmationDialog("Add Photo", isPresented: $showAddPhotoOptions, titleVisibility: .visible) {
            if canTakePhoto {
                Button("Take Photo") {
                    showCameraPicker = true
                }
            }
            Button("Photo Library") {
                showPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(canTakePhoto ? "Choose where to add the record photo from." : "Choose a photo from your library.")
        }
        .confirmationDialog("Remove Photo?", isPresented: $showRemovePhotoConfirmation, titleVisibility: .visible) {
            Button("Remove Photo", role: .destructive) {
                image = nil
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will remove the attached photo from the record.")
        }
        .cameraPicker(isPresented: $showCameraPicker, image: $image)
        .plantPhotoPicker(isPresented: $showPhotoPicker, image: $image)
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
#if canImport(UIKit)
        return Image(uiImage: image)
#elseif canImport(AppKit)
        return Image(nsImage: image)
#else
        return nil
#endif
    }

    private func handleTap() {
        if image == nil {
            showAddPhotoOptions = true
        } else {
            showRemovePhotoConfirmation = true
        }
    }

    private var canTakePhoto: Bool {
#if canImport(UIKit)
        UIImagePickerController.isSourceTypeAvailable(.camera)
#else
        false
#endif
    }
}
