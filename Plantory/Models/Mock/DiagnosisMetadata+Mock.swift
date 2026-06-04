import Foundation

extension DiagnosisMetadata {
    static let overwateringStress = DiagnosisMetadata(
        result: DiagnosisResult(
            species: "Monstera deliciosa",
            problem: "Mild overwatering stress",
            causes: ["Soil stayed damp for too long"],
            suggestions: ["Wait for the top soil to dry before watering again"],
            rawResponse: ""
        )
    )
}
