import SwiftUI

struct PlantInformationPage: View {
    private let initialInfo: PlantInformation?
    private let catalogID: String?
    private let service = PlantInformationCloudService()

    @State private var loadedInfo: PlantInformation?
    @State private var isLoading: Bool
    @State private var errorMessage: String?

    init(info: PlantInformation) {
        initialInfo = info
        catalogID = nil
        _loadedInfo = State(initialValue: info)
        _isLoading = State(initialValue: false)
    }

    init(catalogID: String) {
        initialInfo = nil
        self.catalogID = catalogID
        _loadedInfo = State(initialValue: nil)
        _isLoading = State(initialValue: true)
    }

    var body: some View {
        PixelPage {
            if let info = loadedInfo {
                informationContent(info)
            } else {
                loadingContent
            }
        }
        .pixelBottomActionBar {
            Button("Add to my garden", systemImage: "plus") {
                
            }
            .buttonStyle(.pixelRoundedRectangle(width: .expanded))
        }
        .task(id: catalogID) {
            await loadInformationIfNeeded()
        }
    }
}

#Preview {
    NavigationStack {
        PlantInformationPage(info: .monstera)
    }
}

#Preview("Cloud") {
    NavigationStack {
        PlantInformationPage(catalogID: "monstera-deliciosa")
    }
}

private extension PlantInformationPage {
    func informationContent(_ info: PlantInformation) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                PixelNavigationBar(title: "Plant Info")

                PixelPlantInformationHero(info: info)

                PixelRoundedRectangleCard(
                    title: "Overview",
                    systemImage: "text.book.closed.fill"
                ) {
                    Text(info.displayOverview)
                        .font(.pixel(.body))
                        .foregroundStyle(Color.pixelInk.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

                PixelRoundedRectangleCard(
                    title: "Care Tips",
                    systemImage: "sparkles"
                ) {
                    Text(info.tips)
                        .font(.pixel(.body))
                        .foregroundStyle(Color.pixelInk.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }

                PixelRoundedRectangleCard(
                    title: "Care Guide",
                    systemImage: "leaf.fill"
                ) {
                    PlantInformationCareGuide(info: info)
                }
            }
            .padding(.bottom, 24)
        }
    }

    var loadingContent: some View {
        VStack(spacing: 16) {
            PixelNavigationBar(title: "Plant Info")

            PixelRoundedRectangleCard {
                if isLoading {
                    PixelProgressView("Loading plant information...")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else {
                    PixelContentUnavailableView(
                        "Plant Info Unavailable",
                        systemImage: "icloud.slash.fill",
                        description: LocalizedStringKey(errorMessage ?? String(localized: "Plant information could not be loaded."))
                    ) {
                        Button("Retry", systemImage: "arrow.clockwise") {
                            Task { await loadInformationIfNeeded(force: true) }
                        }
                        .buttonStyle(.pixelRoundedRectangle(size: .small))
                    }
                }
            }
        }
    }

    func loadInformationIfNeeded(force: Bool = false) async {
        if let initialInfo, !force {
            loadedInfo = initialInfo
            isLoading = false
            return
        }

        guard let catalogID else { return }
        guard force || loadedInfo == nil else { return }

        isLoading = true
        errorMessage = nil

        do {
            loadedInfo = try await service.fetchPlantInformation(catalogID: catalogID)
        } catch {
            errorMessage = String(localized: "Plant information could not be loaded.")
        }

        isLoading = false
    }
}
