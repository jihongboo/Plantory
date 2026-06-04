import SwiftData
import SwiftUI

struct PlantInformationPage: View {
    let info: PlantInformation

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PlantInfoInformationCard(info: info)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .navigationTitle(info.commonName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(info: Plant.healthy.information!)
    }
    .modelContainer(.preview)
}
