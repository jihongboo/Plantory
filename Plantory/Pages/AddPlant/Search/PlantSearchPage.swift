import SwiftUI
import SwiftData

/// 手动输入植物名称，并交给 AI 返回完整植物资料。
struct PlantSearchPage: View {
    @Binding var selectedInfo: PlantInformation?

    @Environment(\.dismiss) private var dismiss

    @State private var plantName = ""
    @State private var generatedInfo: PlantInformation?
    @State private var generatedResult: DoubaoPlantRecognitionService.IdentificationResult?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Plant Name") {
                    TextField("Enter plant name", text: $plantName)
                        .textInputAutocapitalization(.words)

                    Button("Generate Plant Info") {
                        Task {
                            await generatePlantInfo()
                        }
                    }
                    .disabled(trimmedPlantName == nil || isLoading)
                }

                if isLoading {
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("Generating plant information...")
                                .foregroundStyle(.secondary)
                        }
                    }
                } else if let generatedInfo {
                    Section("AI Result") {
                        PlantInfoInformationCard(info: generatedInfo)
                    }

                    if let generatedResult {
                        Section("Summary") {
                            LabeledContent("Confidence", value: "\(generatedResult.structuredResult.confidence)%")
                            Text(generatedResult.structuredResult.summary)
                            Text(generatedResult.structuredResult.overview)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Button("Use This Plant") {
                            selectedInfo = generatedInfo
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if let errorMessage {
                    Section("Result") {
                        Text(errorMessage)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Search Plant")
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

#Preview {
    @Previewable @State var selectedInfo: PlantInformation?
    Rectangle()
        .fill(.background)
        .sheet(isPresented: .constant(true)) {
            PlantSearchPage(selectedInfo: $selectedInfo)
        }
        .modelContainer(.preview)
}

private extension PlantSearchPage {
    var trimmedPlantName: String? {
        let trimmed = plantName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    @MainActor
    func generatePlantInfo() async {
        guard let trimmedPlantName, !isLoading else { return }

        isLoading = true
        generatedInfo = nil
        generatedResult = nil
        errorMessage = nil

        do {
            let result = try await DoubaoPlantRecognitionService.identifyPlant(named: trimmedPlantName)
            generatedResult = result
            generatedInfo = result.plantInformation

            if generatedInfo == nil {
                errorMessage = "AI could not generate a complete plant profile from that name."
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
