import SwiftUI

struct AddPlantMenuView: View {
    @State private var isPresentingLibrary = false

    var body: some View {
        Button {
            isPresentingLibrary = true
        } label: {
            Label("Add Plant", systemImage: "plus")
        }
        .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        .accessibilityLabel("Add Plant")
        .accessibilityHint("Open the plant encyclopedia and choose a plant to add.")
        .sheet(isPresented: $isPresentingLibrary) {
            NavigationStack {
                PlantInformationLibraryPage()
            }
        }
    }
}

#Preview {
    AddPlantMenuView()
}
