import SwiftUI
import PhotosUI
import Observation
import UIKit
@preconcurrency import AVFoundation

enum PlantPhotoImportPurpose {
    case addPlant
    case diagnosis
}

struct CameraPickerPage: View {
    let purpose: PlantPhotoImportPurpose
    @Binding var isPresented: Bool
    @Binding var image: PlatformImage?

    @State private var camera = PlantCameraController()
    @State private var pickerItem: PhotosPickerItem?

    init(
        purpose: PlantPhotoImportPurpose = .addPlant,
        isPresented: Binding<Bool>,
        image: Binding<PlatformImage?>
    ) {
        self.purpose = purpose
        _isPresented = isPresented
        _image = image
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    CameraPreviewView(session: camera.session)
                        .ignoresSafeArea()
                        .blur(radius: 6)
                        .overlay(.pixelInk.opacity(0.48))

                    cameraChrome(in: geometry.size)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await camera.start()
            }
            .onDisappear {
                camera.stop()
            }
            .onChange(of: camera.capturedImage) {
                guard let capturedImage = camera.capturedImage else { return }
                image = capturedImage
                isPresented = false
            }
            .photosPicker(
                isPresented: $camera.isPhotoLibraryPresented,
                selection: $pickerItem,
                matching: .images,
                preferredItemEncoding: .current
            )
            .onChange(of: pickerItem) {
                guard let pickerItem else { return }
                Task {
                    image = await loadImage(from: pickerItem)
                    self.pickerItem = nil
                    if image != nil {
                        isPresented = false
                    }
                }
            }
        }
    }

}

private extension AVCaptureDevice.FlashMode {
    var systemImage: String {
        switch self {
        case .off:
            "bolt.slash.fill"
        case .on:
            "bolt.fill"
        case .auto:
            "bolt.badge.a.fill"
        @unknown default:
            "bolt.slash.fill"
        }
    }
}

private struct CameraPickerModifier: ViewModifier {
    let purpose: PlantPhotoImportPurpose
    @Binding var isPresented: Bool
    @Binding var image: PlatformImage?

    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                CameraPickerPage(
                    purpose: purpose,
                    isPresented: $isPresented,
                    image: $image
                )
            }
    }
}

extension View {
    func cameraPicker(
        purpose: PlantPhotoImportPurpose = .addPlant,
        isPresented: Binding<Bool>,
        image: Binding<PlatformImage?>
    ) -> some View {
        modifier(CameraPickerModifier(
            purpose: purpose,
            isPresented: isPresented,
            image: image
        ))
    }
}

#Preview {
    CameraPickerPage(isPresented: .constant(true), image: .constant(nil))
}

private extension CameraPickerPage {
    func cameraChrome(in size: CGSize) -> some View {
        VStack(spacing: 0) {
            cameraTopBar

            Spacer(minLength: 26)

            cameraPanel(maxWidth: min(size.width - 28, 368))

            Spacer(minLength: 18)
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 18)
        .frame(width: size.width, height: size.height)
    }

    var cameraTopBar: some View {
        HStack {
            Button {
                isPresented = false
            } label: {
                Image(systemName: "chevron.left")
                    .font(.pixel(.headline))
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle(fill: .pixelWood))
            .accessibilityLabel("Close")

            Spacer()

            Text("Take Plant Photo")
                .font(.pixel(.largeTitle))
                .foregroundStyle(.white)
                .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)

            Spacer()

            Button {
                camera.toggleZoom()
            } label: {
                Image(systemName: "questionmark")
                    .font(.pixel(.headline))
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.pixelRectangle(fill: .pixelWood))
            .accessibilityLabel("Zoom")
            .accessibilityValue(camera.zoomLabel)
            .opacity(0)
        }
        .padding(.horizontal, 2)
    }

    func cameraPanel(maxWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            Text("对准植物拍摄\n确保光线充足")
                .font(.pixel(.title2))
                .foregroundStyle(.white.opacity(0.82))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)
                .padding(.top, 38)

            Spacer()

            PixelCameraViewfinder()

            Spacer()

            bottomBar
        }
        .frame(maxWidth: maxWidth)
        .frame(maxHeight: .infinity)
    }

    var bottomBar: some View {
        HStack {
            cameraAssetButton(
                title: "相册",
                imageName: "PixelCameraGalleryButton",
                imageSize: 80
            ) {
                camera.isPhotoLibraryPresented = true
            }

            Spacer()

            Button {
                camera.capturePhoto()
            } label: {
                Image("PixelCameraShutterButton")
                    .pixelate()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
            }
            .buttonStyle(.plain)
            .disabled(!camera.isReady)
            .opacity(camera.isReady ? 1 : 0.58)
            .accessibilityLabel("Take Plant Photo")

            Spacer()

            cameraAssetButton(
                title: "开灯",
                imageName: "PixelCameraFlashButton",
                imageSize: 80,
                isEnabled: camera.isFlashAvailable
            ) {
                camera.toggleFlash()
            }
        }
    }

    func cameraAssetButton(
        title: LocalizedStringKey,
        imageName: String,
        imageSize: CGFloat,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Image(imageName)
                    .pixelate()
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize, height: imageSize)

                Text(title)
                    .font(.pixel(.headline))
                    .foregroundStyle(.white)
                    .shadow(color: .pixelInk, radius: 0, x: 2, y: 2)
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1 : 0.46)
    }

    func loadImage(from item: PhotosPickerItem) async -> PlatformImage? {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        return PlatformImage(data: data)
    }
}

private struct PixelCameraViewfinder: View {
    var body: some View {
        PixelRectangleBackground(fill: .clear)
            .aspectRatio(1, contentMode: .fit)
            .accessibilityHidden(true)
    }
}
