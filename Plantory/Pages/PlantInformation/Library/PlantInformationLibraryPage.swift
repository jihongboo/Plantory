import SwiftUI

struct PlantInformationLibraryPage: View {
    @State private var viewState: ViewState<[PlantInformation]>
    @State private var searchText = ""

    private let service = PlantInformationCloudService()
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    init(_ initialState: ViewState<[PlantInformation]>? = nil) {
        _viewState = State(initialValue: initialState ?? .loading)
    }

    var body: some View {
        PixelPage {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    PixelNavigationBar(title: "Plant Encyclopedia", subtitle: "\(filteredInfos.count) plants")

                    PixelRoundedRectangleCard(
                        title: "Find Plants",
                        systemImage: "magnifyingglass"
                    ) {
                        TextField("Search by name or species", text: $searchText)
                            .textFieldStyle(.pixel)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled()
                    }

                    content
                }
                .padding(.bottom, 24)
            }
            .refreshable {
                await loadInformation()
            }
        }
        .task {
            if !AppEnvironment.isPreview {
                await loadInformation()
            }
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        PlantInformationLibraryPage(.loaded([.monstera, .succulent]))
    }
}

#Preview("Loading") {
    NavigationStack {
        PlantInformationLibraryPage(.loading)
    }
}

#Preview("Failed") {
    NavigationStack {
        PlantInformationLibraryPage(.failed(AppError.custom("CloudKit unavailable")))
    }
}

private extension PlantInformationLibraryPage {
    @ViewBuilder
    var content: some View {
        switch viewState {
        case .loading:
            PixelRoundedRectangleCard {
                PixelProgressView("Loading CloudKit plants...")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
        case .failed(let error):
            PixelRoundedRectangleCard {
                PixelContentUnavailableView(
                    "CloudKit Error",
                    systemImage: "icloud.slash.fill",
                    description: LocalizedStringKey(error.localizedDescription)
                ) {
                    Button("Retry", systemImage: "arrow.clockwise") {
                        Task { await loadInformation() }
                    }
                }
            }
        case .loaded:
            if filteredInfos.isEmpty {
                PixelContentUnavailableView(
                    "No Plants Found",
                    systemImage: "magnifyingglass",
                    description: trimmedSearchText.isEmpty
                    ? "CloudKit did not return any published plants."
                    : "Try a different plant name or species."
                )
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(filteredInfos) { info in
                        NavigationLink {
                            PlantInformationPage(info: info)
                        } label: {
                            PlantInformationLibraryCard(info: info)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var infos: [PlantInformation] {
        viewState.value ?? []
    }

    var filteredInfos: [PlantInformation] {
        guard !trimmedSearchText.isEmpty else { return infos }

        return infos.filter {
            $0.commonName.localizedCaseInsensitiveContains(trimmedSearchText)
                || $0.species.localizedCaseInsensitiveContains(trimmedSearchText)
        }
    }

    func loadInformation() async {
        viewState = .loading

        do {
            viewState = .loaded(try await service.fetchPlantInformations())
        } catch {
            viewState = .failed(error)
        }
    }
}
