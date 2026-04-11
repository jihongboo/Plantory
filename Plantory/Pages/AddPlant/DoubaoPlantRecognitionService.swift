import Foundation

#if canImport(UIKit) || canImport(AppKit)
enum DoubaoPlantRecognitionService {
    private static let endpoint = URL(string: "https://ark.cn-beijing.volces.com/api/v3/responses")!
    private static let apiKey = "c2620045-55b5-45ce-9e8d-0d517846c643"
    private static let model = "doubao-seed-2-0-mini-260215"

    static func identifyPlant(
        imageData: Data
    ) async throws -> IdentificationResult {
        let payload = try makeImagePayload(imageData: imageData)
        var request = URLRequest(url: endpoint)
        try configure(&request, payload: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        return try decodeIdentificationResult(from: data)
    }

    static func identifyPlantWithDiagnosis(
        imageData: Data
    ) async throws -> CombinedAnalysisResult {
        let payload = try makeCombinedImagePayload(imageData: imageData)
        var request = URLRequest(url: endpoint)
        try configure(&request, payload: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        let apiResponse = try JSONDecoder().decode(DoubaoResponse.self, from: data)
        let outputText = try apiResponse.outputTextValue()
        let structured = try decodeCombinedStructuredResult(from: outputText)

        return CombinedAnalysisResult(
            identification: IdentificationResult(
                plantInformation: structured.recognition.plantInformation,
                structuredResult: structured.recognition,
                rawOutputText: outputText
            ),
            diagnosisReport: structured.diagnosis.report,
            rawOutputText: outputText
        )
    }

    static func identifyPlant(
        named plantName: String
    ) async throws -> IdentificationResult {
        let payload = makeNamePayload(plantName: plantName)
        var request = URLRequest(url: endpoint)
        try configure(&request, payload: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        try validate(response: response, data: data)

        return try decodeIdentificationResult(from: data)
    }
}

private extension DoubaoPlantRecognitionService {
    static func configure(_ request: inout URLRequest, payload: RequestBody) throws {
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
    }

    static func decodeIdentificationResult(from data: Data) throws -> IdentificationResult {
        let apiResponse = try JSONDecoder().decode(DoubaoResponse.self, from: data)
        let outputText = try apiResponse.outputTextValue()
        let structured = try decodeStructuredResult(from: outputText)
        let plantInformation = structured.plantInformation

        return IdentificationResult(
            plantInformation: plantInformation,
            structuredResult: structured,
            rawOutputText: outputText
        )
    }
}

extension DoubaoPlantRecognitionService {
    struct IdentificationResult {
        let plantInformation: PlantInformation?
        let structuredResult: StructuredPlantRecognition
        let rawOutputText: String
    }

    struct CombinedAnalysisResult {
        let identification: IdentificationResult
        let diagnosisReport: PlantDiagnosisReport
        let rawOutputText: String
    }

    struct StructuredPlantRecognition: Decodable {
        let commonName: String?
        let species: String?
        let confidence: Int
        let isPlant: Bool
        let overview: String
        let careDifficulty: String
        let lightLevel: String
        let summary: String
        let light: String
        let waterLevel: String
        let water: String
        let humidityLevel: String
        let temperature: String
        let diseaseRiskLevel: String
        let fertilizerLevel: String
        let fertilizer: String
        let tips: String

        var displayName: String? {
            nonEmpty(commonName) ?? nonEmpty(species)
        }

        var plantInformation: PlantInformation? {
            guard isPlant,
                  let species = nonEmpty(species),
                  let commonName = nonEmpty(commonName) else {
                return nil
            }

            return PlantInformation(
                species: species,
                commonName: commonName,
                overview: overview,
                careDifficulty: normalizedLevel(careDifficulty, allowed: ["easy", "moderate", "hard"], fallback: "moderate"),
                lightLevel: normalizedLevel(lightLevel, allowed: ["low", "medium", "high"], fallback: "medium"),
                light: light,
                waterLevel: normalizedLevel(waterLevel, allowed: ["low", "medium", "high"], fallback: "medium"),
                water: water,
                humidityLevel: normalizedLevel(humidityLevel, allowed: ["low", "medium", "high"], fallback: "medium"),
                temperature: temperature,
                diseaseRiskLevel: normalizedLevel(diseaseRiskLevel, allowed: ["low", "medium", "high"], fallback: "medium"),
                fertilizerLevel: normalizedLevel(fertilizerLevel, allowed: ["low", "medium", "high"], fallback: "medium"),
                fertilizer: fertilizer,
                tips: tips
            )
        }
    }

    fileprivate struct StructuredCombinedPlantAnalysis: Decodable {
        let recognition: StructuredPlantRecognition
        let diagnosis: StructuredDiagnosis
    }
}

private extension DoubaoPlantRecognitionService {
    struct RequestBody: Encodable {
        let model: String
        let input: [InputMessage]
        let thinking: Thinking
    }
    
    struct Thinking: Encodable {
        let type: String
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
        let status: String?

        enum CodingKeys: String, CodingKey {
            case outputText = "output_text"
            case output
            case status
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

                let fallbackText = output
                    .flatMap { $0.content ?? [] }
                    .compactMap(\.text)
                    .joined(separator: "\n")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if !fallbackText.isEmpty {
                    return fallbackText
                }
            }

            throw ServiceError.emptyResponse
        }
    }

    struct OutputItem: Decodable {
        let type: String?
        let role: String?
        let status: String?
        let content: [OutputContent]?
        let summary: [OutputSummary]?
    }

    struct OutputContent: Decodable {
        let type: String?
        let text: String?
    }

    struct OutputSummary: Decodable {
        let type: String?
        let text: String?
    }

    struct APIErrorResponse: Decodable {
        let error: APIErrorDetail?
    }

    struct APIErrorDetail: Decodable {
        let message: String?
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
                "The photo could not be prepared for upload."
            case .invalidResponse:
                "The AI service returned an unexpected response."
            case .apiFailure(let message):
                message
            case .emptyResponse:
                "The AI service did not return any result."
            case .invalidJSON(let rawText):
                "The AI service returned an unreadable result: \(rawText)"
            }
        }
    }

    static func makeImagePayload(
        imageData: Data
    ) throws -> RequestBody {
        guard let compressedImageData = ImageCompression.compressedJPEGData(
            from: imageData,
            profile: ImageCompression.recognitionUploadProfile
        ) else {
            throw ServiceError.invalidImage
        }

        let prompt = imageRecognitionPrompt()
        let dataURL = "data:image/jpeg;base64,\(compressedImageData.base64EncodedString())"

        return RequestBody(
            model: model,
            input: [
                InputMessage(
                    role: "user",
                    content: [
                        InputContent(type: "input_image", imageURL: dataURL, text: nil),
                        InputContent(type: "input_text", imageURL: nil, text: prompt)
                    ]
                )
            ],
            thinking: .init(type: "disabled")
        )
    }

    static func makeCombinedImagePayload(
        imageData: Data
    ) throws -> RequestBody {
        guard let compressedImageData = ImageCompression.compressedJPEGData(
            from: imageData,
            profile: ImageCompression.diagnosisUploadProfile
        ) else {
            throw ServiceError.invalidImage
        }

        let prompt = combinedImageAnalysisPrompt()
        let dataURL = "data:image/jpeg;base64,\(compressedImageData.base64EncodedString())"

        return RequestBody(
            model: model,
            input: [
                InputMessage(
                    role: "user",
                    content: [
                        InputContent(type: "input_image", imageURL: dataURL, text: nil),
                        InputContent(type: "input_text", imageURL: nil, text: prompt)
                    ]
                )
            ],
            thinking: .init(type: "disabled")
        )
    }

    static func makeNamePayload(plantName: String) -> RequestBody {
        RequestBody(
            model: model,
            input: [
                InputMessage(
                    role: "user",
                    content: [
                        InputContent(
                            type: "input_text",
                            imageURL: nil,
                            text: nameLookupPrompt(plantName: plantName)
                        )
                    ]
                )
            ],
            thinking: .init(type: "disabled")
        )
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

    static func decodeStructuredResult(from text: String) throws -> StructuredPlantRecognition {
        let jsonText = extractJSONObject(from: text)

        guard let data = jsonText.data(using: .utf8) else {
            throw ServiceError.invalidJSON(text)
        }

        do {
            return try JSONDecoder().decode(StructuredPlantRecognition.self, from: data)
        } catch {
            throw ServiceError.invalidJSON(text)
        }
    }

    static func decodeCombinedStructuredResult(from text: String) throws -> StructuredCombinedPlantAnalysis {
        let jsonText = extractJSONObject(from: text)

        guard let data = jsonText.data(using: .utf8) else {
            throw ServiceError.invalidJSON(text)
        }

        do {
            return try JSONDecoder().decode(StructuredCombinedPlantAnalysis.self, from: data)
        } catch {
            throw ServiceError.invalidJSON(text)
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

    static func imageRecognitionPrompt() -> String {
        return """
        你是一名植物识别与养护信息整理助手。请根据图片识别植物，并且只能输出一个 JSON 对象，不要输出 markdown，不要输出解释性前后缀。

        任务要求：
        1. 先判断图片主体是否是一株植物。
        2. 如果是植物，请直接给出植物名称和基础养护信息。
        3. 如果无法准确识别具体品种，请尽量给出最合理的常见名称或属名。
        4. `confidence` 必须是 0 到 100 的整数。
        5. 所有文本字段都用简洁中文。
        6. 你必须量化以下字段，并且只能从固定枚举中选择：
           `careDifficulty`: easy | moderate | hard
           `lightLevel`: low | medium | high
           `waterLevel`: low | medium | high
           `humidityLevel`: low | medium | high
           `diseaseRiskLevel`: low | medium | high
           `fertilizerLevel`: low | medium | high
        7. `light`、`water`、`temperature`、`fertilizer`、`tips` 必须给出可直接展示给用户的内容。
        8. 如果图里不是植物，`isPlant` 返回 false，植物相关字段统一返回 null 或空字符串，量化字段统一返回默认中间值。

        返回 JSON，字段必须完整，格式如下：
        {
          "commonName": "龟背竹" | null,
          "species": "Monstera deliciosa" | null,
          "confidence": 0,
          "isPlant": true,
          "overview": "一种常见观叶植物，叶片有自然裂口。",
          "careDifficulty": "moderate",
          "lightLevel": "medium",
          "summary": "图片中是一盆龟背竹，叶片开裂明显。",
          "light": "明亮散射光，避免长时间暴晒。",
          "waterLevel": "medium",
          "water": "土壤表层 2 到 3 厘米变干后再浇透。",
          "humidityLevel": "high",
          "temperature": "18 到 30 摄氏度。",
          "diseaseRiskLevel": "medium",
          "fertilizerLevel": "medium",
          "fertilizer": "生长期每月施一次稀薄观叶肥。",
          "tips": "保持通风和一定空气湿度，能让叶片状态更好。"
        }
        """
    }

    static func combinedImageAnalysisPrompt() -> String {
        """
        你是一名植物识别与病害诊断助手。请根据图片同时完成“植物识别”和“健康诊断”，并且只能输出一个 JSON 对象，不要输出 markdown，不要输出解释性前后缀。

        总要求：
        1. 先判断图片主体是否是一株植物。
        2. 如果是植物，返回植物名称、基础养护信息、以及这张图对应的健康诊断。
        3. 如果无法准确识别具体品种，请尽量给出最合理的常见名称或属名。
        4. 如果图里不是植物，`recognition.isPlant` 返回 false；植物识别字段返回 null 或空字符串；诊断部分默认按低风险返回，不要编造严重病害。
        5. `recognition.confidence` 和 `diagnosis.confidence` 都必须是 0 到 100 的整数。
        6. `recognition` 中所有自然语言字段使用简洁中文。
        7. `diagnosis` 中所有自然语言字段使用简洁英文，方便当前页面直接展示。

        `recognition` 要求：
        1. 量化字段只能从固定枚举中选择：
           `careDifficulty`: easy | moderate | hard
           `lightLevel`: low | medium | high
           `waterLevel`: low | medium | high
           `humidityLevel`: low | medium | high
           `diseaseRiskLevel`: low | medium | high
           `fertilizerLevel`: low | medium | high

        `diagnosis` 要求：
        1. `urgency` 只能是 `low`、`medium`、`high`。
        2. `healthStatus` 只能是 `healthy`、`warning`、`critical`。
        3. `primaryIssueType` 只能是以下之一或 null：
           `underwatered` `overwatered` `pestInfestation` `nutrientDeficiency` `rootRot` `sunburn` `insufficientLight` `fungalDisease` `other`
        4. `primaryIssueSeverity` 只能是 `mild`、`moderate`、`severe` 或 null。
        5. `observedSignals` 返回 2 到 4 项，每项 `systemImage` 只能从以下枚举中选择：
           `leaf` `drop` `sun.max` `ladybug` `wind` `thermometer` `eye` `sparkles` `exclamationmark.triangle`
        6. `possibleCauses` 返回 2 到 4 条。
        7. `carePlan` 返回 2 到 4 条，每条包含 `title`、`detail`、`timing`。
        8. `watchItems` 返回 2 条。
        9. `preventionTip` 返回 1 条简洁建议。

        返回 JSON，字段必须完整，格式如下：
        {
          "recognition": {
            "commonName": "龟背竹" | null,
            "species": "Monstera deliciosa" | null,
            "confidence": 0,
            "isPlant": true,
            "overview": "一种常见观叶植物，叶片有自然裂口。",
            "careDifficulty": "moderate",
            "lightLevel": "medium",
            "summary": "图片中是一盆龟背竹，叶片开裂明显。",
            "light": "明亮散射光，避免长时间暴晒。",
            "waterLevel": "medium",
            "water": "土壤表层 2 到 3 厘米变干后再浇透。",
            "humidityLevel": "high",
            "temperature": "18 到 30 摄氏度。",
            "diseaseRiskLevel": "medium",
            "fertilizerLevel": "medium",
            "fertilizer": "生长期每月施一次稀薄观叶肥。",
            "tips": "保持通风和一定空气湿度，能让叶片状态更好。"
          },
          "diagnosis": {
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
        }
        """
    }

    static func nameLookupPrompt(plantName: String) -> String {
        """
        你是一名植物资料整理助手。用户输入了一个植物名称：\(plantName)

        请根据这个名称返回一个 JSON 对象，不要输出 markdown，不要输出解释性前后缀。

        任务要求：
        1. 尽量识别出该植物最常见的中文名和学名。
        2. 如果名称模糊，请返回最可能的常见植物，并在 `summary` 里简要说明。
        3. `confidence` 必须是 0 到 100 的整数。
        4. 所有文本字段都用简洁中文。
        5. 你必须量化以下字段，并且只能从固定枚举中选择：
           `careDifficulty`: easy | moderate | hard
           `lightLevel`: low | medium | high
           `waterLevel`: low | medium | high
           `humidityLevel`: low | medium | high
           `diseaseRiskLevel`: low | medium | high
           `fertilizerLevel`: low | medium | high
        6. `light`、`water`、`temperature`、`fertilizer`、`tips` 必须给出可直接展示给用户的内容。
        7. 如果输入明显不是植物名称，`isPlant` 返回 false，植物相关字段统一返回 null 或空字符串，量化字段统一返回默认中间值。

        返回 JSON，字段必须完整，格式如下：
        {
          "commonName": "龟背竹" | null,
          "species": "Monstera deliciosa" | null,
          "confidence": 0,
          "isPlant": true,
          "overview": "一种常见观叶植物，叶片有自然裂口。",
          "careDifficulty": "moderate",
          "lightLevel": "medium",
          "summary": "龟背竹是常见室内观叶植物，适合明亮散射光环境。",
          "light": "明亮散射光，避免长时间暴晒。",
          "waterLevel": "medium",
          "water": "土壤表层 2 到 3 厘米变干后再浇透。",
          "humidityLevel": "high",
          "temperature": "18 到 30 摄氏度。",
          "diseaseRiskLevel": "medium",
          "fertilizerLevel": "medium",
          "fertilizer": "生长期每月施一次稀薄观叶肥。",
          "tips": "保持通风和一定空气湿度，能让叶片状态更好。"
        }
        """
    }

    static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedLevel(_ value: String, allowed: Set<String>, fallback: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return allowed.contains(normalized) ? normalized : fallback
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
#endif
