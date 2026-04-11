import SwiftUI

enum AddPlantCardPreviewSupport {
    static let imageData = PlatformImageData.named("Monstera deliciosa") ?? Data()

    static let plantInformation = PreviewData.healthyPlant.information ?? PlantInformation.catalog.first!

    static let recognition = DoubaoPlantRecognitionService.IdentificationResult(
        plantInformation: plantInformation,
        structuredResult: DoubaoPlantRecognitionService.StructuredPlantRecognition(
            commonName: plantInformation.commonName,
            species: plantInformation.species,
            confidence: 96,
            isPlant: true,
            overview: plantInformation.displayOverview,
            careDifficulty: plantInformation.careDifficulty,
            lightLevel: plantInformation.lightLevel,
            summary: "\(plantInformation.commonName) recognized from preview mock data.",
            light: plantInformation.light,
            waterLevel: plantInformation.waterLevel,
            water: plantInformation.water,
            humidityLevel: plantInformation.humidityLevel,
            temperature: plantInformation.temperature,
            diseaseRiskLevel: plantInformation.diseaseRiskLevel,
            fertilizerLevel: plantInformation.fertilizerLevel,
            fertilizer: plantInformation.fertilizer,
            tips: plantInformation.tips
        ),
        rawOutputText: "Preview mock recognition result"
    )

    static let diagnosisReport = PlantDiagnosisReport(
        speciesName: plantInformation.species,
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

    static var image: Image? {
        Image(data: imageData)
    }
}
