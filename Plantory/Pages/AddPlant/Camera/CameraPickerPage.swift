import SwiftUI

#if canImport(UIKit)
import UIKit

private struct CameraPickerPage: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var image: PlatformImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerPage

        init(_ parent: CameraPickerPage) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.editedImage] as? UIImage
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.image = nil
            parent.isPresented = false
        }
    }
}

private struct CameraPickerModifier: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var image: PlatformImage?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                CameraPickerPage(isPresented: $isPresented, image: $image)
                    .ignoresSafeArea()
            }
    }
}

extension View {
    func cameraPicker(isPresented: Binding<Bool>, image: Binding<PlatformImage?>) -> some View {
        modifier(CameraPickerModifier(isPresented: isPresented, image: image))
    }
}
#else
extension View {
    func cameraPicker(isPresented: Binding<Bool>, image: Binding<PlatformImage?>) -> some View {
        self
    }
}
#endif
