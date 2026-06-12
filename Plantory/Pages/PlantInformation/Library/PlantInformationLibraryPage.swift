import SwiftData
import SwiftUI
import NavigatorUI

struct PlantInformationLibraryPage: View {
    @Environment(\.modelContext) private var modelContext

    @State private var viewState: ViewState<[PlantInformation]>
    @State private var searchText = ""

    private let loadsOnAppear: Bool
    private let service = PlantInformationCloudService()
    init(_ plantInformations: [PlantInformation] = []) {
        loadsOnAppear = !AppEnvironment.isPreview
        _viewState = State(initialValue: plantInformations.isEmpty ? .loading : .loaded(plantInformations))
    }

    init(initialState: ViewState<[PlantInformation]>) {
        loadsOnAppear = false
        _viewState = State(initialValue: initialState)
    }

    var body: some View {
        PixelPage {
            Group {
                switch viewState {
                case .loading:
                    PixelProgressView("Loading plant encyclopedia...")
                case .loaded:
                    content
                case .failed(let error):
                    PixelContentUnavailableView(error: error) {
                        Button("Retry", systemImage: "arrow.circlepath") {
                            Task {
                                await load()
                            }
                        }
                        .buttonStyle(.pixelRoundedRectangle)
                    }
                    .scenePadding()
                }
            }
            .task {
                guard loadsOnAppear else { return }
                await load()
            }
            .pixelNavigationTitle(title: "Plant Encyclopedia", subtitle: "\(filteredInfos.count) plants")
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        PlantInformationLibraryPage(initialState: .loaded([.monstera, .succulent]))
    }
    .modelContainer(.preview)
}

#Preview("Loading") {
    NavigationStack {
        PlantInformationLibraryPage(initialState: .loading)
    }
    .modelContainer(.preview)
}

#Preview("Failed") {
    NavigationStack {
        PlantInformationLibraryPage(initialState: .failed(AppError.empty))
    }
    .modelContainer(.preview)
}

private extension PlantInformationLibraryPage {
    @ViewBuilder
    var content: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 4) {
                PixelRoundedRectangleCard(
                    title: "Find Plants",
                    systemImage: "magnifyingglass"
                ) {
                    TextField("Search by name or species", text: $searchText)
                        .textFieldStyle(.pixel)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }

                LazyVStack(spacing: 4) {
                    ForEach(filteredInfos) { info in
                        NavigationLink(to: PlantoryDestination.plantInformation(PlantInformationRoute(plantInformation: info))) {
                            PlantInformationLibraryCard(info: info)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }

    var plantInformations: [PlantInformation] {
        viewState.value ?? []
    }

    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var filteredInfos: [PlantInformation] {
        guard !trimmedSearchText.isEmpty else { return plantInformations }

        return plantInformations.filter { $0.matchesSearchText(trimmedSearchText) }
    }

    func load() async {
        if viewState.value == nil,
           let localPlantInformations = try? service.localPlantInformations(in: modelContext),
           !localPlantInformations.isEmpty {
            viewState = .loaded(localPlantInformations)
        }

        do {
            let refreshedPlantInformations = try await service.fetchPlantInformations(in: modelContext)
            if refreshedPlantInformations.isEmpty {
                viewState = .failed(AppError.empty)
                return
            }

            viewState = .loaded(refreshedPlantInformations)
        } catch {
            if viewState.value == nil {
                viewState = .failed(error)
                return
            }
        }

    }
}
