import SwiftUI
import SwiftData

/// 手动添加植物：填写别名 + 从植物目录中搜索选择种类。
struct PlantSearchPage: View {
    @Binding var selectedInfo: PlantInformation?
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \PlantInformation.commonName) private var allInfos: [PlantInformation]
    @State private var searchText = ""
    private let recommendedInfos = PlantInformation.catalog
    
    private var searchResults: [PlantInformation] {
        guard !searchText.isEmpty else { return allInfos }
        return allInfos.filter {
            $0.commonName.localizedStandardContains(searchText) ||
            $0.species.localizedStandardContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if searchText.isEmpty {
                    Section("Recommended Plants") {
                        if recommendedInfos.isEmpty {
                            Text("No recommendations available yet")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(recommendedInfos) { info in
                                PlantSelectionButton(
                                    info: info,
                                    selection: $selectedInfo
                                )
                            }
                        }
                    }
                } else {
                    Section("Search Results") {
                        if searchResults.isEmpty {
                            Text("No matching plants")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(searchResults) { info in
                                PlantSelectionButton(
                                    info: info,
                                    selection: $selectedInfo
                                )
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: Text("Search plant"))
            .navigationTitle("Select a Plant")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var selectedInfo: PlantInformation?
    Rectangle()
        .fill(.background)
        .sheet(isPresented: .constant(true)) {
            PlantSearchPage(selectedInfo: $selectedInfo)
        }
        .modelContainer(.preview)
}
