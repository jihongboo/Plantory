import Foundation

struct PlantDiagnosisReport: Identifiable {
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

enum DoubaoPlantDiagnosisService {
    private static let endpoint = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!
    private static let apiKey = "c2620045-55b5-45ce-9e8d-0d517846c643"
    private static let model = "doubao-seed-2-0-mini-260215"

    static func analyze(
        plant: Plant,
        image: PlatformImage
    ) async throws -> PlantDiagnosisReport {
        guard let compressedImageData = ImageCompression.compressedJPEGData(
            from: image,
            profile: ImageCompression.diagnosisUploadProfile
        ) else {
            throw ServiceError.invalidImage
        }

        let payload = RequestBody(
            model: model,
            input: [
                InputMessage(
                    role: "user",
                    content: [
                        InputContent(
                            type: "input_image",
                            imageURL: "data:image/jpeg;base64,\(compressedImageData.base64EncodedString())",
                            text: nil
                        ),
                        InputContent(
                            type: "input_text",
                            imageURL: nil,
                            text: diagnosisPrompt(for: plant)
                        )
                    ]
                )
            ]
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let apiResponse = try JSONDecoder().decode(DoubaoResponse.self, from: data)
        let outputText = try apiResponse.outputTextValue()
        let jsonText = extractJSONObject(from: outputText)
        guard let jsonData = jsonText.data(using: .utf8) else {
            throw ServiceError.invalidJSON(outputText)
        }

        let structured = try JSONDecoder().decode(StructuredDiagnosis.self, from: jsonData)
        return structured.report
    }
}

private extension DoubaoPlantDiagnosisService {
    struct RequestBody: Encodable {
        let model: String
        let input: [InputMessage]
    }

    struct InputMessage: Encodable {
        let role: String
        let content: [InputContent]
    }

    struct InputContent: Encodable {
        let type: String
        let imageURL: String?
        let text: String?

        enum CodingKeys: String, CodingKey {
            case type
            case imageURL = "image_url"
            case text
        }
    }

    struct DoubaoResponse: Decodable {
        let outputText: String?
        let output: [OutputItem]?

        enum CodingKeys: String, CodingKey {
            case outputText = "output_text"
            case output
        }

        func outputTextValue() throws -> String {
            if let outputText, !outputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return outputText
            }

            if let output {
                let assistantText = output
                    .filter { $0.type == "message" && $0.role == "assistant" }
                    .flatMap { $0.content ?? [] }
                    .first { $0.type == "output_text" }?
                    .text?
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if let assistantText, !assistantText.isEmpty {
                    return assistantText
                }
            }

            throw ServiceError.emptyResponse
        }
    }

    struct OutputItem: Decodable {
        let type: String?
        let role: String?
        let content: [OutputContent]?
    }

    struct OutputContent: Decodable {
        let type: String?
        let text: String?
    }

    struct APIErrorResponse: Decodable {
        let error: APIErrorDetail?
    }

    struct APIErrorDetail: Decodable {
        let message: String?
    }

    struct StructuredDiagnosis: Decodable {
        let speciesName: String
        let title: String
        let summary: String
        let confidence: Int
        let urgency: String
        let healthStatus: String
        let primaryIssueType: String?
        let primaryIssueSeverity: String?
        let primaryIssueNote: String?
        let observedSignals: [StructuredSignal]
        let possibleCauses: [String]
        let carePlan: [StructuredAction]
        let watchItems: [String]
        let preventionTip: String

        var report: PlantDiagnosisReport {
            PlantDiagnosisReport(
                speciesName: speciesName,
                title: title,
                summary: summary,
                confidence: min(max(confidence, 0), 100),
                urgency: DiagnosisUrgency(rawValue: urgency) ?? .medium,
                healthStatus: healthStatusValue,
                primaryIssue: primaryIssueValue,
                observedSignals: observedSignals.map(\.signal),
                possibleCauses: possibleCauses,
                carePlan: carePlan.map(\.action),
                watchItems: watchItems,
                preventionTip: preventionTip
            )
        }

        var healthStatusValue: HealthStatus {
            switch healthStatus {
            case "healthy":
                .healthy
            case "critical":
                .critical
            default:
                .warning
            }
        }

        var primaryIssueValue: PlantIssue? {
            guard let primaryIssueType,
                  let type = IssueType(rawValue: primaryIssueType),
                  let primaryIssueSeverity,
                  let severity = IssueSeverity(rawValue: primaryIssueSeverity) else {
                return nil
            }

            return PlantIssue(type: type, severity: severity, note: primaryIssueNote ?? "")
        }
    }

    struct StructuredSignal: Decodable {
        let title: String
        let detail: String
        let systemImage: String

        var signal: DiagnosisSignal {
            DiagnosisSignal(
                title: title,
                detail: detail,
                systemImage: allowedSymbol(systemImage)
            )
        }
    }

    struct StructuredAction: Decodable {
        let title: String
        let detail: String
        let timing: String

        var action: DiagnosisAction {
            DiagnosisAction(title: title, detail: detail, timing: timing)
        }
    }

    enum ServiceError: LocalizedError {
        case invalidImage
        case invalidResponse
        case apiFailure(String)
        case emptyResponse
        case invalidJSON(String)

        var errorDescription: String? {
            switch self {
            case .invalidImage:
                "The diagnosis photo could not be prepared for upload."
            case .invalidResponse:
                "The AI diagnosis service returned an unexpected response."
            case .apiFailure(let message):
                message
            case .emptyResponse:
                "The AI diagnosis service returned no diagnosis."
            case .invalidJSON(let rawText):
                "The AI diagnosis result could not be parsed: \(rawText)"
            }
        }
    }

    static func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            let message = apiError?.error?.message ?? "The AI service failed with status code \(httpResponse.statusCode)."
            throw ServiceError.apiFailure(message)
        }
    }

    static func extractJSONObject(from text: String) -> String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.hasPrefix("{"), trimmed.hasSuffix("}") {
            return trimmed
        }

        guard let start = trimmed.firstIndex(of: "{"),
              let end = trimmed.lastIndex(of: "}") else {
            return trimmed
        }

        return String(trimmed[start ... end])
    }

    static func diagnosisPrompt(for plant: Plant) -> String {
        let species = plant.information?.species ?? ""
        let commonName = plant.information?.commonName ?? plant.displayName
        let note = plant.note.trimmingCharacters(in: .whitespacesAndNewlines)

        return """
        你是一名植物病害与养护诊断助手。请根据这张植物照片做一次诊断，并且只能输出一个 JSON 对象，不要输出 markdown，不要输出解释性前后缀。

        已知植物信息：
        - commonName: \(commonName)
        - species: \(species.isEmpty ? "unknown" : species)
        - extraNote: \(note.isEmpty ? "none" : note)

        输出要求：
        1. 根据叶片、颜色、斑点、萎蔫、虫害迹象等判断最可能的问题。
        2. `confidence` 必须是 0 到 100 的整数。
        3. `urgency` 只能是 `low`、`medium`、`high`。
        4. `healthStatus` 只能是 `healthy`、`warning`、`critical`。
        5. `primaryIssueType` 只能是以下之一或 null：
           `underwatered` `overwatered` `pestInfestation` `nutrientDeficiency` `rootRot` `sunburn` `insufficientLight` `fungalDisease` `other`
        6. `primaryIssueSeverity` 只能是 `mild`、`moderate`、`severe` 或 null。
        7. `observedSignals` 返回 2 到 4 项，每项 `systemImage` 只能从以下枚举中选择：
           `leaf` `drop` `sun.max` `ladybug` `wind` `thermometer` `eye` `sparkles` `exclamationmark.triangle`
        8. `possibleCauses` 返回 2 到 4 条。
        9. `carePlan` 返回 2 到 4 条，每条包含 `title`、`detail`、`timing`。
        10. `watchItems` 返回 2 条。
        11. `preventionTip` 返回 1 条简洁建议。
        12. 所有自然语言字段用简洁英文，方便当前页面直接展示。

        JSON 格式：
        {
          "speciesName": "Monstera deliciosa",
          "title": "Overwatering with root stress risk",
          "summary": "The photo suggests persistent moisture stress with yellowing and soft droop.",
          "confidence": 91,
          "urgency": "high",
          "healthStatus": "critical",
          "primaryIssueType": "rootRot",
          "primaryIssueSeverity": "severe",
          "primaryIssueNote": "Yellow patches and drooping suggest likely root stress.",
          "observedSignals": [
            {
              "title": "Yellowing zones",
              "detail": "Older leaves are losing color first.",
              "systemImage": "drop"
            }
          ],
          "possibleCauses": [
            "Watering happened before the soil had dried."
          ],
          "carePlan": [
            {
              "title": "Pause watering",
              "detail": "Let the top layer dry before watering again.",
              "timing": "Immediately"
            }
          ],
          "watchItems": [
            "A sour smell from the pot can point to root rot."
          ],
          "preventionTip": "Check soil dryness before every watering."
        }
        """
    }

    static func allowedSymbol(_ value: String) -> String {
        let allowed = Set([
            "leaf",
            "drop",
            "sun.max",
            "ladybug",
            "wind",
            "thermometer",
            "eye",
            "sparkles",
            "exclamationmark.triangle"
        ])

        return allowed.contains(value) ? value : "leaf"
    }
}
