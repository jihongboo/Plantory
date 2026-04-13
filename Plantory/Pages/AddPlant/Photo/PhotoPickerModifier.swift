//
//  PlantPhotoPickerModifier.swift
//  Plantory
//
//  Created by 纪洪波 on 2026/3/11.
//

import SwiftUI
import PhotosUI
import Photos

private struct PhotoPickerModifier: ViewModifier {
    private static let requestedPixelSize = CGSize(width: 1400, height: 1400)

    @Binding var isPresented: Bool
    @Binding var image: PlatformImage?
    @State private var pickerItem: PhotosPickerItem?

    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $isPresented,
                selection: $pickerItem,
                matching: .images,
                preferredItemEncoding: .current
            )
            .onChange(of: pickerItem) {
                guard let pickerItem else { return }
                Task {
                    image = await loadPlatformImage(from: pickerItem)
                    self.pickerItem = nil
                }
            }
    }

    private func loadPlatformImage(from item: PhotosPickerItem) async -> PlatformImage? {
        let selectedData = try? await item.loadTransferable(type: Data.self)
        if let selectedData,
           let image = PlatformImage(data: selectedData) {
            return image
        }

        if let itemIdentifier = item.itemIdentifier,
           let photoKitImage = await requestImage(for: itemIdentifier) {
            return photoKitImage
        }

        return nil
    }

    private func requestImage(for itemIdentifier: String) async -> PlatformImage? {
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [itemIdentifier], options: nil)
        guard let asset = assets.firstObject else { return nil }

        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: Self.requestedPixelSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

extension View {
    func plantPhotoPicker(isPresented: Binding<Bool>, image: Binding<PlatformImage?>) -> some View {
        modifier(PhotoPickerModifier(isPresented: isPresented, image: image))
    }
}
