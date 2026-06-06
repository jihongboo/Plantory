import SwiftUI

struct PlantInformationPage: View {
    private let id: String?
    private let service = PlantInformationCloudService()
    
    @State private var plantInformation: PlantInformation?
    
    init(plantInformation: PlantInformation) {
        id = nil
        _plantInformation = .init(initialValue: plantInformation)
    }
    
    init(id: String) {
        self.id = id
        _plantInformation = .init(initialValue: nil)
    }
    
    var body: some View {
        PixelPage {
            Group {
                if let plantInformation {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            PlantInformationHeader(info: plantInformation)
                            
                            PixelRoundedRectangleCard(
                                title: "Overview",
                                systemImage: "text.book.closed.fill"
                            ) {
                                Text(plantInformation.displayOverview)
                                    .font(.pixel(.body))
                                    .foregroundStyle(Color.pixelInk.opacity(0.78))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            PixelRoundedRectangleCard(
                                title: "Care Guide",
                                systemImage: "leaf.fill"
                            ) {
                                PlantInformationCareGuide(info: plantInformation)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                } else {
                    Spacer()
                }
            }
            .load {
                if let id {
                    plantInformation = try await service.fetchPlantInformation(catalogID: id)
                }
            }
            .pixelNavigationTitle(title: "Plant Info")
        }
        .pixelBottomActionBar {
            NavigationLink {
                if let plantInformation {
                    AddPlantPage(plantInformation: plantInformation)
                }
            } label: {
                Label("Add to my garden", systemImage: "plus")
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            .disabled(plantInformation == nil)
        }
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(plantInformation: .monstera)
    }
}

#Preview("Cloud") {
    NavigationStack {
        PlantInformationPage(id: "monstera-deliciosa")
    }
}
