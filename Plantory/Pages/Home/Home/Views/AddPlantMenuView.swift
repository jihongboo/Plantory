import SwiftUI
import NavigatorUI

struct AddPlantMenuView: View {
    @Environment(\.navigator) private var navigator

    var body: some View {
        Button {
            navigator
                .present(
                    sheet: PlantoryDestination.plantInformationLibrary(.add),
                    managed: true
                )
        } label: {
            Label("Add Plant", systemImage: "plus")
        }
        .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        .accessibilityLabel("Add Plant")
        .accessibilityHint("Open the plant encyclopedia and choose a plant to add.")
    }
}

#Preview {
    AddPlantMenuView()
}
