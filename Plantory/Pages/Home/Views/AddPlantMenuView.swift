import SwiftUI

struct AddPlantMenuView: View {
    @State private var imageData: Data?

    var body: some View {
        PlantImageImportMenu { preparedImageData in
            imageData = preparedImageData
        } label: { isPreparingImage in
            Label("Add Plant", systemImage: "plus")
        }
        .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        .accessibilityLabel("Identify")
        .accessibilityHint("Recognize a plant from a photo and add it to your collection.")
        .sheet(item: $imageData) { imageData in
            AddPlantView(imageData: imageData)
        }
    }
}

#Preview {
    AddPlantMenuView()
}
