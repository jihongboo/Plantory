import SwiftUI
import SwiftData

// MARK: - AddPlantView

/// 统一处理图片添加和自定义添加，并负责最终保存。
struct AddPlantView: View {
    let imageData: Data
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var plantInformation: PlantInformation?
    @State private var nickname = ""
    @State private var isLoading = true
    @Query(sort: \PlantInformation.commonName) private var allInfos: [PlantInformation]
    
    var body: some View {
        NavigationStack {
            Form {
                // 拍摄的照片缩略图
                imageView
                
                // 识别结果
                if isLoading {
                    EmptyView()
                } else {
                    if let info = plantInformation {
                        Section("Plant information") {
                            PlantInfoInformationCard(info: info)
                        }
                        
                        Section("Additional information") {
                            TextField("Nickname (optional)", text: $nickname)
                            Button("Get location", systemImage: "location.fill") {
                                
                            }
                        }
                    } else {
                        Text("Could not identify the plant. You can still add it manually.")
                        
                        Section("Select from existing plants") {
                            NavigationLink {
                                PlantSearchPage(selectedInfo: $plantInformation)
                            } label: {
                                Label("earch for a plant", systemImage: "magnifyingglass")
                            }
                        }
                    }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .task {
                // Mock：模拟 1.5 秒识别延迟，随机选取一种植物
                try? await Task.sleep(for: .seconds(1.5))
                plantInformation = allInfos.randomElement()
                isLoading = false
            }
            .navigationTitle("Add Plant")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        addPlant()
                    }
                    .disabled(isSaveDisabled)
                    .bold()
                }
            }
        }
    }
    
    private var imageView: some View {
        Section {
            if let PlantImage {
                ZStack {
                    Rectangle()
                        .fill(.background)
                        .aspectRatio(1, contentMode: .fit)
                    PlantImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 160)
                        .shadow(radius: 4)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    AddPlantView(imageData: PreviewAssets.samplePlantPhotoData!)
        .modelContainer(.preview)
}

private extension AddPlantView {
    var PlantImage: Image? {
        Image(data: imageData)
    }
    
    var isSaveDisabled: Bool {
        PlantImage == nil || plantInformation == nil
    }
    
    func trimmedNickname() -> String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    func addPlant() {
        let plant = Plant(
            nickname: trimmedNickname(),
            imageData: imageData,
            information: plantInformation
        )
        modelContext.insert(plant)
        dismiss()
    }
}

private enum PreviewAssets {
    static let samplePlantPhotoData: Data? = PlatformImageData.named("Monstera deliciosa")
}
