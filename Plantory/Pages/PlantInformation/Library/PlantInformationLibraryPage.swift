import SwiftData
import SwiftUI

struct PlantInformationLibraryPage: View {
    @Environment(\.modelContext) private var modelContext

    @State private var plantInformations: [PlantInformation] = []
    @State private var searchText = ""

    private let service = PlantInformationCloudService()
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(_ plantInformations: [PlantInformation] = []) {
        _plantInformations = State(initialValue: plantInformations)
    }

    var body: some View {
        PixelPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    PixelRoundedRectangleCard(
                        title: "Find Plants",
                        systemImage: "magnifyingglass"
                    ) {
                        TextField("Search by name or species", text: $searchText)
                            .textFieldStyle(.pixel)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredInfos) { info in
                            NavigationLink {
                                PlantInformationPage(plantInformation: info)
                            } label: {
                                PlantInformationLibraryCard(info: info)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .load(load)
                }
                .padding(.bottom, 24)
            }
            .pixelNavigationTitle(title: "Plant Encyclopedia", subtitle: "\(filteredInfos.count) plants")
        }
    }
}

#Preview {
    NavigationStack {
        PlantInformationLibraryPage([.monstera, .succulent])
    }
}

#Preview("Remote") {
    NavigationStack {
        PlantInformationLibraryPage([])
    }
}

private extension PlantInformationLibraryPage {

    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var filteredInfos: [PlantInformation] {
        guard !trimmedSearchText.isEmpty else { return plantInformations }

        return plantInformations.filter { $0.matchesSearchText(trimmedSearchText) }
    }

    func load() async throws {
        if !plantInformations.isEmpty { return }
        plantInformations = (try? service.localPlantInformations(in: modelContext)) ?? []

        do {
            plantInformations = try await service.fetchPlantInformations(in: modelContext)
        } catch {
            if plantInformations.isEmpty {
                throw error
            }
        }

        if plantInformations.isEmpty {
            throw AppError.empty
        }
    }
}
