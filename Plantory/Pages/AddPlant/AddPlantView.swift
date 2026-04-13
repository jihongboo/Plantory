import Foundation
import SwiftData
import SwiftUI

enum AddPlantDiagnosisState {
    case idle
    case analyzing
    case failed(String)
    case complete(PlantDiagnosisReport)
}

struct AddPlantView: View {
    let imageData: Data

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var plantInformation: PlantInformation?
    @State private var recognitionResult: DoubaoPlantRecognitionService.IdentificationResult?
    @State private var diagnosisState: AddPlantDiagnosisState = .idle
    @State private var nickname = ""
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    AddPlantPhotoHeroCard(
                        image: plantImage,
                        displayName: heroDisplayName,
                        nickname: $nickname
                    )

                    if isLoading {
                        AddPlantLoadingCard()
                    } else if let info = plantInformation {
                        if let recognitionResult {
                            AddPlantRecognitionSummaryCard(result: recognitionResult)
                        }
                        
                        PlantInfoInformationCard(info: info)

                        AddPlantDiagnosisCard(
                            state: diagnosisState,
                            retryAction: { Task { await identifyPlant() } }
                        )
                    } else {
                        AddPlantFailureCard(
                            recognitionResult: recognitionResult,
                            errorMessage: errorMessage
                        )
                        AddPlantDiagnosisCard(
                            state: diagnosisState,
                            retryAction: { Task { await identifyPlant() } }
                        )
                        AddPlantManualEntryCard(plantInformation: $plantInformation)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
            }
            .background(.background)
            .task(id: imageData) {
                await identifyPlant()
            }
            .navigationTitle("Add Plant")
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
}

// MARK: - Preview

#Preview {
    AddPlantView(imageData: PreviewAssets.samplePlantPhotoData!)
        .modelContainer(.preview)
}

private extension AddPlantView {
    var plantImage: Image? {
        Image(data: imageData)
    }

    var isSaveDisabled: Bool {
        plantImage == nil || plantInformation == nil
    }

    var heroDisplayName: String? {
        let trimmed = trimmedNickname()
        return trimmed ?? plantInformation?.commonName ?? recognitionResult?.structuredResult.displayName
    }

    func trimmedNickname() -> String? {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func identifyPlant() async {
        isLoading = true
        diagnosisState = .analyzing

        if AppEnvironment.isPreview {
            let mockResult = previewMockResult()
            recognitionResult = mockResult.identification
            plantInformation = mockResult.identification.plantInformation
            if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                nickname = mockResult.identification.plantInformation?.commonName
                ?? mockResult.identification.structuredResult.displayName
                ?? ""
            }
            diagnosisState = .complete(mockResult.diagnosisReport)
            errorMessage = nil
            isLoading = false
            return
        }

        do {
            let result = try await DoubaoPlantRecognitionService.identifyPlantWithDiagnosis(imageData: imageData)
            recognitionResult = result.identification
            plantInformation = result.identification.plantInformation
            if nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                nickname = result.identification.plantInformation?.commonName
                ?? result.identification.structuredResult.displayName
                ?? ""
            }
            diagnosisState = .complete(result.diagnosisReport)
            errorMessage = plantInformation == nil ? "AI could not identify a complete plant profile from this photo. You can still add it manually." : nil
        } catch {
            plantInformation = nil
            recognitionResult = nil
            diagnosisState = .failed(error.localizedDescription)
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addPlant() {
        guard let plantInformation else { return }

        let persistedInformation: PlantInformation
        if let existing = existingPlantInformation(matching: plantInformation) {
            persistedInformation = existing
        } else {
            persistedInformation = plantInformation
            modelContext.insert(persistedInformation)
        }

        let plant = Plant(
            nickname: trimmedNickname(),
            imageData: imageData,
            information: persistedInformation
        )

        if case .complete(let report) = diagnosisState {
            if let primaryIssue = report.primaryIssue {
                plant.activeIssues = [primaryIssue]
            }

            let record = PlantRecord(
                note: "AI diagnosis suggests \(report.title.lowercased()).",
                photoData: imageData,
                diagnosis: DiagnosisMetadata(result: report.diagnosisResult),
                plant: plant
            )

            if plant.records == nil {
                plant.records = []
            }
            plant.records?.insert(record, at: 0)
            modelContext.insert(record)
        }

        modelContext.insert(plant)
        dismiss()
    }

    func existingPlantInformation(matching candidate: PlantInformation) -> PlantInformation? {
        let normalizedSpecies = normalized(candidate.species)
        let normalizedCommonName = normalized(candidate.commonName)

        let descriptor = FetchDescriptor<PlantInformation>()
        guard let infos = try? modelContext.fetch(descriptor) else { return nil }

        return infos.first {
            normalized($0.species) == normalizedSpecies ||
            normalized($0.commonName) == normalizedCommonName
        }
    }

    func normalized(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }

    func previewMockResult() -> DoubaoPlantRecognitionService.CombinedAnalysisResult {
        let info = PreviewData.healthyPlant.information ?? PlantInformation.catalog.first!
        let recognition = DoubaoPlantRecognitionService.StructuredPlantRecognition(
            commonName: info.commonName,
            species: info.species,
            confidence: 96,
            isPlant: true,
            overview: info.displayOverview,
            careDifficulty: info.careDifficulty,
            lightLevel: info.lightLevel,
            summary: "\(info.commonName) recognized from preview mock data.",
            light: info.light,
            waterLevel: info.waterLevel,
            water: info.water,
            humidityLevel: info.humidityLevel,
            temperature: info.temperature,
            diseaseRiskLevel: info.diseaseRiskLevel,
            fertilizerLevel: info.fertilizerLevel,
            fertilizer: info.fertilizer,
            tips: info.tips
        )

        let report = PlantDiagnosisReport(
            speciesName: info.species,
            title: "Mild overwatering stress",
            summary: "Preview mode uses mock diagnosis data so the screen can render without calling the AI service.",
            confidence: 92,
            urgency: .medium,
            healthStatus: .warning,
            primaryIssue: PlantIssue(
                type: .overwatered,
                severity: .mild,
                note: "Generated from preview mock data."
            ),
            observedSignals: [
                DiagnosisSignal(
                    title: "Yellow leaf edge",
                    detail: "Older leaves show slight yellowing near the margin.",
                    systemImage: "leaf"
                ),
                DiagnosisSignal(
                    title: "Moist soil",
                    detail: "Top soil appears wetter than expected for this care cycle.",
                    systemImage: "drop"
                )
            ],
            possibleCauses: [
                "Watering before the top layer of soil dried out",
                "Lower airflow around the pot after the last watering"
            ],
            carePlan: [
                DiagnosisAction(
                    title: "Delay the next watering",
                    detail: "Let the top 2-3 cm of soil dry before watering again.",
                    timing: "Today"
                ),
                DiagnosisAction(
                    title: "Increase airflow",
                    detail: "Move the pot to a brighter, better-ventilated spot with indirect light.",
                    timing: "This week"
                )
            ],
            watchItems: [
                "Check whether yellowing spreads to new leaves",
                "Monitor soil moisture for the next 3-5 days"
            ],
            preventionTip: "Keep a consistent dry-down cycle between waterings."
        )

        return DoubaoPlantRecognitionService.CombinedAnalysisResult(
            identification: DoubaoPlantRecognitionService.IdentificationResult(
                plantInformation: info,
                structuredResult: recognition,
                rawOutputText: "Preview mock recognition result"
            ),
            diagnosisReport: report,
            rawOutputText: "Preview mock combined result"
        )
    }
}

enum PreviewAssets {
    static let samplePlantPhotoData: Data? = PlatformImageData.named("Monstera deliciosa")
}
