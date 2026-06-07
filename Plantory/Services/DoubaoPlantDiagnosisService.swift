import Foundation
import SwiftUI

struct PlantDiagnosisReport: Identifiable {
    let id = UUID()
    let speciesName: String
    let title: String
    let summary: String
    let confidence: Int
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

enum DoubaoPlantDiagnosisService {
    private static let endpoint = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!
    private static let apiKey = "c2620045-55b5-45ce-9e8d-0d517846c643"
    private static let model = "doubao-seed-2-0-mini-260215"

    static func analyze(
        plant: Plant,
        image: PlatformImage
    ) async throws -> PlantDiagnosisReport {
        try await analyze(image: image, prompt: diagnosisPrompt(for: plant))
    }

    static func analyze(image: PlatformImage) async throws -> PlantDiagnosisReport {
        try await analyze(image: image, prompt: temporaryDiagnosisPrompt())
    }
}

private extension DoubaoPlantDiagnosisService {
    static func analyze(image: PlatformImage, prompt: String) async throws -> PlantDiagnosisReport {
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
                            text: prompt
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

        var report: PlantDiagnosisReport {
            PlantDiagnosisReport(
                speciesName: speciesName,
                title: title,
                summary: summary,
                confidence: min(max(confidence, 0), 100),
            )
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
                String(localized: "The diagnosis photo could not be prepared for upload.")
            case .invalidResponse:
                String(localized: "The AI diagnosis service returned an unexpected response.")
            case .apiFailure(let message):
                message
            case .emptyResponse:
                String(localized: "The AI diagnosis service returned no diagnosis.")
            case .invalidJSON(let rawText):
                String(
                    format: String(localized: "The AI diagnosis result could not be parsed: %@"),
                    locale: Locale.current,
                    rawText
                )
            }
        }
    }

    static func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.invalidResponse
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            let apiError = try? JSONDecoder().decode(APIErrorResponse.self, from: data)
            let message = apiError?.error?.message ?? String(
                format: String(localized: "The AI service failed with status code %lld."),
                locale: Locale.current,
                httpResponse.statusCode
            )
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
        let language = AppLanguage.current
        let note = plant.note.trimmingCharacters(in: .whitespacesAndNewlines)

        return diagnosisPrompt(
            language: language,
            commonName: plant.displayName,
            species: plant.plantInformation?.species ?? "",
            note: note
        )
    }

    static func temporaryDiagnosisPrompt() -> String {
        let language = AppLanguage.current
        return diagnosisPrompt(
            language: language,
            commonName: language.unknownPlantValue,
            species: language.unknownPlantValue,
            note: String(localized: "Temporary diagnosis without a saved plant profile.")
        )
    }

    static func diagnosisPrompt(
        language: AppLanguage,
        commonName: String,
        species: String,
        note: String
    ) -> String {
        switch language {
        case .english:
            return """
            You are a plant diagnosis and care assistant. Analyze this plant photo and return exactly one JSON object. Do not output markdown or any extra explanation.

            Known plant information:
            - preferredLanguage: \(language.apiLanguageCode)
            - commonName: \(commonName)
            - species: \(species.isEmpty ? language.unknownPlantValue : species)
            - extraNote: \(note.isEmpty ? language.emptyPromptNoteValue : note)

            Output requirements:
            1. Diagnose the most likely issue based on leaves, color, spots, drooping, pest signs, and other visible signals.
            2. `confidence` must be an integer from 0 to 100.
            3. `urgency` must be `low`, `medium`, or `high`.
            4. `healthStatus` must be `healthy`, `warning`, or `critical`.
            5. `primaryIssueType` must be one of these or null:
               `underwatered` `overwatered` `pestInfestation` `nutrientDeficiency` `rootRot` `sunburn` `insufficientLight` `fungalDisease` `other`
            6. `primaryIssueSeverity` must be `mild`, `moderate`, `severe`, or null.
            7. `observedSignals` must contain 2 to 4 items. Each `systemImage` must be one of:
               `leaf` `drop` `sun.max` `ladybug` `wind` `thermometer` `eye` `sparkles` `exclamationmark.triangle`
            8. `possibleCauses` must contain 2 to 4 items.
            9. `carePlan` must contain 2 to 4 items, each with `title`, `detail`, and `timing`.
            10. `watchItems` must contain 2 items.
            11. `preventionTip` must contain 1 concise tip.
            12. All natural-language fields must be concise \(language.aiLanguageName).

            JSON shape:
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
        case .simplifiedChinese:
            return """
        你是一名植物病害与养护诊断助手。请根据这张植物照片做一次诊断，并且只能输出一个 JSON 对象，不要输出 markdown，不要输出解释性前后缀。

        已知植物信息：
        - preferredLanguage: \(language.apiLanguageCode)
        - commonName: \(commonName)
        - species: \(species.isEmpty ? language.unknownPlantValue : species)
        - extraNote: \(note.isEmpty ? language.emptyPromptNoteValue : note)

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
        12. 所有自然语言字段用简洁中文。

        JSON 格式：
        {
          "speciesName": "Monstera deliciosa",
          "title": "浇水过多并伴随根系受压风险",
          "summary": "照片显示叶片发黄且轻微软塌，存在持续湿害迹象。",
          "confidence": 91,
          "urgency": "high",
          "healthStatus": "critical",
          "primaryIssueType": "rootRot",
          "primaryIssueSeverity": "severe",
          "primaryIssueNote": "叶片发黄和下垂提示根系可能已经受压。",
          "observedSignals": [
            {
              "title": "叶片发黄区域",
              "detail": "老叶先开始失去绿色。",
              "systemImage": "drop"
            }
          ],
          "possibleCauses": [
            "盆土未干就再次浇水。"
          ],
          "carePlan": [
            {
              "title": "暂停浇水",
              "detail": "等待盆土表层变干后再补水。",
              "timing": "立即执行"
            }
          ],
          "watchItems": [
            "盆土出现酸臭味可能提示烂根。"
          ],
          "preventionTip": "每次浇水前先确认盆土干湿度。"
        }
        """
        }
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
