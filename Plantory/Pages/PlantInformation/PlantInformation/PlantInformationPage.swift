import SwiftData
import SwiftUI

struct PlantInformationPage: View {
    @Environment(\.modelContext) private var modelContext

    private let catalogID: String?
    private let loadsOnAppear: Bool
    private let service = PlantInformationCloudService()

    @State private var viewState: ViewState<PlantInformation>

    init(plantInformation: PlantInformation) {
        catalogID = plantInformation.catalogID
        loadsOnAppear = !AppEnvironment.isPreview
        _viewState = .init(initialValue: .loaded(plantInformation))
    }

    init(id: String, initialState: ViewState<PlantInformation>? = nil) {
        catalogID = id
        loadsOnAppear = !AppEnvironment.isPreview
        _viewState = .init(initialValue: initialState ?? .loading)
    }

    init(initialState: ViewState<PlantInformation>) {
        catalogID = initialState.value?.catalogID
        loadsOnAppear = false
        _viewState = .init(initialValue: initialState)
    }

    var body: some View {
        PixelPage {
            Group {
                switch viewState {
                case .loading:
                    PixelProgressView()
                case .loaded(let plantInformation):
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
            .pixelNavigationTitle(title: "Plant Info")
        }
        .pixelBottomActionBar {
            NavigationLink {
                if let plantInformation = viewState.value {
                    AddPlantPage(plantInformation: plantInformation)
                }
            } label: {
                Label("Add to my garden", systemImage: "plus")
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
            .disabled(viewState.value == nil)
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        PlantInformationPage(initialState: .loaded(.monstera))
    }
    .modelContainer(.preview)
}

#Preview("Loading") {
    NavigationStack {
        PlantInformationPage(initialState: .loading)
    }
    .modelContainer(.preview)
}

#Preview("Failed") {
    NavigationStack {
        PlantInformationPage(initialState: .failed(AppError.empty))
    }
    .modelContainer(.preview)
}

private extension PlantInformationPage {
    func load() async {
        guard let catalogID else { return }

        if viewState.value == nil,
           let localInformation = try? service.localPlantInformation(catalogID: catalogID, in: modelContext) {
            viewState = .loaded(localInformation)
        }

        do {
            let refreshedInformation = try await service.fetchPlantInformation(
                catalogID: catalogID,
                in: modelContext
            )
            viewState = .loaded(refreshedInformation)
        } catch {
            if viewState.value == nil {
                viewState = .failed(error)
            }
        }
    }
}
