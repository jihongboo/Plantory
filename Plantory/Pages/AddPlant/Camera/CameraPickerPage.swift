import SwiftUI
import PhotosUI
import Observation
import UIKit
@preconcurrency import AVFoundation

enum PlantPhotoImportPurpose {
    case addPlant
    case diagnosis

    var navigationTitle: LocalizedStringKey {
        switch self {
        case .addPlant:
            "Add Plant Photo"
        case .diagnosis:
            "Diagnose Plant"
        }
    }

    var captureTitle: LocalizedStringKey {
        switch self {
        case .addPlant:
            "Take Plant Photo"
        case .diagnosis:
            "Take Diagnosis Photo"
        }
    }
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
            ZStack {
                Color.blue.ignoresSafeArea()

                CameraPreviewView(session: camera.session)
                    .ignoresSafeArea()

                LinearGradient(
                    colors: [.black.opacity(0.72), .clear, .black.opacity(0.82)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                cameraChrome
            }
            .navigationTitle(purpose.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark") {
                        isPresented = false
                    }
                }
                
                ToolbarItemGroup(placement: .primaryAction) {
                    Button("Flash", systemImage: camera.flashMode.systemImage) {
                        camera.toggleFlash()
                    }
                    .disabled(!camera.isFlashAvailable)

                    Button("Zoom", systemImage: "plus.magnifyingglass") {
                        camera.toggleZoom()
                    }
                    .accessibilityValue(camera.zoomLabel)
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
    var cameraChrome: some View {
        VStack(spacing: 0) {
            Spacer()

            scanBadge
            
            Spacer()

            bottomBar
        }
        .padding(.horizontal, 24)
        .padding(.top, 18)
        .padding(.bottom, 28)
    }

    var scanBadge: some View {
        Image(systemName: "viewfinder")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.white)
            .font(.system(size: 300, weight: .thin))
    }

    var bottomBar: some View {
        ZStack {
            HStack {
                Button {
                    camera.isPhotoLibraryPresented = true
                } label: {
                    Label("Photo Library", systemImage: "photo.on.rectangle")
                        .padding(8)
                        .labelStyle(.iconOnly)
                        .font(.title2.weight(.semibold))
                }
                .buttonBorderShape(.circle)
                .buttonStyle(.glass)
                
                Spacer()
            }

            Button {
                camera.capturePhoto()
            } label: {
                Label(purpose.captureTitle, systemImage: "camera.fill")
                    .font(.title.weight(.bold))
                    .labelStyle(.iconOnly)
                    .padding()
            }
            .buttonStyle(.glassProminent)
            .tint(.green)
            .buttonBorderShape(.circle)
            .disabled(!camera.isReady)
        }
    }

    func loadImage(from item: PhotosPickerItem) async -> PlatformImage? {
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return nil
        }
        return PlatformImage(data: data)
    }
}
