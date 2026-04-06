import Foundation

struct MockPlantDiagnosisReport: Identifiable {
    let id = UUID()
    let speciesName: String
    let title: String
    let summary: String
    let confidence: Int
    let urgency: DiagnosisUrgency
    let healthStatus: HealthStatus
    let primaryIssue: PlantIssue?
    let observedSignals: [DiagnosisSignal]
    let possibleCauses: [String]
    let carePlan: [DiagnosisAction]
    let watchItems: [String]
    let preventionTip: String

    var diagnosisResult: DiagnosisResult {
        DiagnosisResult(
            species: speciesName,
            problem: title,
            causes: possibleCauses,
            suggestions: carePlan.map(\.title),
            rawResponse: summary
        )
    }
}

struct DiagnosisSignal: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
}

struct DiagnosisAction: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let timing: String
}

enum DiagnosisUrgency: String {
    case low
    case medium
    case high

    var title: String {
        switch self {
        case .low:
            "Low urgency"
        case .medium:
            "Needs care today"
        case .high:
            "Act quickly"
        }
    }

    var subtitle: String {
        switch self {
        case .low:
            "Monitor and keep routine stable."
        case .medium:
            "Adjust care within the next 24 hours."
        case .high:
            "Treat this as the next care priority."
        }
    }
}

enum MockPlantDiagnosisService {
    static func analyze(plant: Plant) async -> MockPlantDiagnosisReport {
        try? await Task.sleep(for: .seconds(1.2))

        let speciesName = plant.information?.species ?? plant.displayName
        let issue = plant.activeIssues.sorted { $0.severity > $1.severity }.first

        switch issue?.type {
        case .underwatered:
            return MockPlantDiagnosisReport(
                speciesName: speciesName,
                title: "Early dehydration stress",
                summary: "The leaves look slightly limp and the soil pattern suggests the plant has stayed dry for longer than ideal.",
                confidence: 86,
                urgency: .medium,
                healthStatus: .warning,
                primaryIssue: PlantIssue(type: .underwatered, severity: .moderate, note: "Leaf edges are curling inward."),
                observedSignals: [
                    DiagnosisSignal(title: "Leaf curl", detail: "Newer leaves are folding inward to reduce water loss.", systemImage: "arrow.trianglehead.2.clockwise.rotate.90"),
                    DiagnosisSignal(title: "Dry soil", detail: "The root zone likely dried out past the usual watering window.", systemImage: "aqi.low"),
                    DiagnosisSignal(title: "Lower leaf softness", detail: "Older foliage may start looking less firm first.", systemImage: "leaf")
                ],
                possibleCauses: [
                    "Recent watering interval was too long.",
                    "Warmer window position increased evaporation.",
                    "Potting mix may now be draining too quickly."
                ],
                carePlan: [
                    DiagnosisAction(title: "Water thoroughly once", detail: "Saturate the soil until water drains through, then discard excess water.", timing: "Now"),
                    DiagnosisAction(title: "Check again in 2 days", detail: "Feel the top 2-3 cm of soil before watering again.", timing: "48h"),
                    DiagnosisAction(title: "Raise humidity slightly", detail: "Move away from direct airflow if AC or heater is nearby.", timing: "This week")
                ],
                watchItems: [
                    "If crisp brown edges spread after watering, root stress may also be involved.",
                    "If leaves recover firmness by tomorrow, the issue was likely simple underwatering."
                ],
                preventionTip: "Tie watering to soil dryness instead of fixed weekdays."
            )
        case .rootRot, .overwatered:
            return MockPlantDiagnosisReport(
                speciesName: speciesName,
                title: "Overwatering with root stress risk",
                summary: "The photo suggests persistent moisture stress. Leaf discoloration and softness are consistent with roots staying wet too long.",
                confidence: 91,
                urgency: .high,
                healthStatus: .critical,
                primaryIssue: PlantIssue(type: .rootRot, severity: .severe, note: "Yellow patches and drooping indicate likely root stress."),
                observedSignals: [
                    DiagnosisSignal(title: "Yellowing zones", detail: "Color loss is concentrated in older leaves first.", systemImage: "drop.triangle"),
                    DiagnosisSignal(title: "Soft droop", detail: "Leaves look heavy rather than crisp, which often points to overwatering.", systemImage: "leaf.arrow.triangle.circlepath"),
                    DiagnosisSignal(title: "Potential compact soil", detail: "The mix may be retaining water for too long around the roots.", systemImage: "square.stack.3d.down.right")
                ],
                possibleCauses: [
                    "Watering happened before the top layer had dried.",
                    "The pot or soil mix may not drain fast enough.",
                    "Roots may have reduced oxygen exposure for several days."
                ],
                carePlan: [
                    DiagnosisAction(title: "Pause watering", detail: "Let the top layer dry before adding any more water.", timing: "Immediately"),
                    DiagnosisAction(title: "Inspect roots when possible", detail: "Check for dark, mushy roots and trim damaged parts if needed.", timing: "Today"),
                    DiagnosisAction(title: "Increase airflow and light", detail: "Bright indirect light helps the mix dry more evenly.", timing: "Today")
                ],
                watchItems: [
                    "A sour smell from the pot is a strong sign of root rot.",
                    "Rapid yellowing on multiple leaves means escalation is likely."
                ],
                preventionTip: "Use a drain-first watering routine and avoid topping up on a schedule."
            )
        case .pestInfestation:
            return MockPlantDiagnosisReport(
                speciesName: speciesName,
                title: "Possible pest activity on foliage",
                summary: "The leaf texture and spotting pattern look consistent with minor pest activity, likely still at an early stage.",
                confidence: 82,
                urgency: .medium,
                healthStatus: .warning,
                primaryIssue: PlantIssue(type: .pestInfestation, severity: .moderate, note: "Fine spotting suggests pests may be feeding under leaves."),
                observedSignals: [
                    DiagnosisSignal(title: "Stippled leaf surface", detail: "Tiny pale dots can appear when pests feed on leaf tissue.", systemImage: "ladybug"),
                    DiagnosisSignal(title: "Patchy dullness", detail: "Affected leaves lose their healthy sheen.", systemImage: "sparkles"),
                    DiagnosisSignal(title: "Localized spread", detail: "Damage appears limited enough for spot treatment.", systemImage: "scope")
                ],
                possibleCauses: [
                    "Spider mites or thrips may be present on the underside of leaves.",
                    "Dry indoor air can increase pest pressure.",
                    "The plant may have been exposed by a recent new plant introduction."
                ],
                carePlan: [
                    DiagnosisAction(title: "Inspect leaf undersides", detail: "Check with bright light and isolate the plant if pests are visible.", timing: "Now"),
                    DiagnosisAction(title: "Wipe and rinse foliage", detail: "Clean the leaves gently before any treatment.", timing: "Today"),
                    DiagnosisAction(title: "Repeat follow-up check", detail: "Reinspect in 3-4 days because eggs may hatch later.", timing: "This week")
                ],
                watchItems: [
                    "Webbing or moving dots confirm a stronger pest case.",
                    "If the newest leaves distort, treatment should become more aggressive."
                ],
                preventionTip: "Quarantine newly added plants for a short period before placing them together."
            )
        default:
            return MockPlantDiagnosisReport(
                speciesName: speciesName,
                title: "Mild watering imbalance",
                summary: "This looks like a manageable stress signal rather than severe disease. The plant likely needs a small care adjustment and observation.",
                confidence: 84,
                urgency: .low,
                healthStatus: .warning,
                primaryIssue: PlantIssue(type: .overwatered, severity: .mild, note: "Slight yellowing on older leaves suggests routine imbalance."),
                observedSignals: [
                    DiagnosisSignal(title: "Older leaf fade", detail: "The oldest foliage is showing the earliest color change.", systemImage: "leaf.fill"),
                    DiagnosisSignal(title: "Overall structure stable", detail: "The plant still appears structurally sound.", systemImage: "checkmark.circle"),
                    DiagnosisSignal(title: "No severe tissue collapse", detail: "There are no clear signs of advanced damage.", systemImage: "heart.text.square")
                ],
                possibleCauses: [
                    "Watering rhythm may be slightly ahead of the soil drying cycle.",
                    "Light conditions may be a bit lower than ideal for current growth.",
                    "Normal aging of older leaves may be amplifying the visual change."
                ],
                carePlan: [
                    DiagnosisAction(title: "Delay the next watering slightly", detail: "Wait until the top soil feels dry before the next session.", timing: "Next watering"),
                    DiagnosisAction(title: "Move to brighter indirect light", detail: "A little more filtered light helps stabilize recovery.", timing: "Today"),
                    DiagnosisAction(title: "Document a comparison photo", detail: "A follow-up image in 5-7 days will show whether the issue is spreading.", timing: "This week")
                ],
                watchItems: [
                    "If yellowing spreads to newer leaves, reassess quickly.",
                    "If only one older leaf declines, it may be normal turnover."
                ],
                preventionTip: "Track changes with photos so minor issues become obvious earlier."
            )
        }
    }
}
