import CloudKit
import Foundation
import SwiftData

struct PlantInformationLocalizedContent: Codable, Hashable {
    var commonName: String?
    var overview: String?
    var tips: String?
}

@Model
final class PlantInformation {
    #Index<PlantInformation>([\.catalogID])

    var catalogID: String = ""
    var species: String = ""
    var commonName: String = ""
    var overview: String = ""
    var imageURL: URL?
    var careDifficulty: String = "moderate"
    var lightLevel: String = "medium"
    var waterLevel: String = "medium"
    var humidityLevel: String = "medium"
    var temperature: String = ""
    var diseaseRiskLevel: String = "medium"
    var fertilizerLevel: String = "medium"
    var localizedContentsJSON: String = "{}"
    var plants: [Plant]?

    init(
        catalogID: String? = nil,
        species: String,
        commonName: String,
        overview: String = "",
        imageURL: URL? = nil,
        careDifficulty: String = "moderate",
        lightLevel: String = "medium",
        waterLevel: String = "medium",
        humidityLevel: String = "medium",
        temperature: String,
        diseaseRiskLevel: String = "medium",
        fertilizerLevel: String? = nil,
        localizedContents: [String: PlantInformationLocalizedContent] = [:]
    ) {
        self.catalogID = catalogID ?? Self.catalogID(commonName: commonName, species: species)
        self.species = species
        self.commonName = commonName
        self.overview = overview
        self.imageURL = imageURL
        self.careDifficulty = Self.normalizedCareDifficulty(careDifficulty)
        self.lightLevel = Self.normalizedLevel(lightLevel)
        self.waterLevel = Self.normalizedLevel(waterLevel)
        self.humidityLevel = Self.normalizedLevel(humidityLevel)
        self.temperature = temperature
        self.diseaseRiskLevel = Self.normalizedLevel(diseaseRiskLevel)
        self.fertilizerLevel = Self.normalizedLevel(fertilizerLevel ?? "medium")
        self.localizedContentsJSON = Self.encodedLocalizedContents(localizedContents)
    }
}

extension PlantInformation {
    static func catalogID(from record: CKRecord) -> String {
        let catalogID = record.stringValue(for: "catalogID")
        return catalogID.isEmpty ? record.recordID.recordName : catalogID
    }

    convenience init(record: CKRecord) {
        self.init(
            catalogID: Self.catalogID(from: record),
            species: record.stringValue(for: "species"),
            commonName: record.stringValue(for: "commonName"),
            overview: record.stringValue(for: "overview"),
            imageURL: Self.imageURL(from: record),
            careDifficulty: record.stringValue(for: "careDifficulty", default: "moderate"),
            lightLevel: record.stringValue(for: "lightLevel", default: "medium"),
            waterLevel: record.stringValue(for: "waterLevel", default: "medium"),
            humidityLevel: record.stringValue(for: "humidityLevel", default: "medium"),
            temperature: record.stringValue(for: "temperature"),
            diseaseRiskLevel: record.stringValue(for: "diseaseRiskLevel", default: "medium"),
            fertilizerLevel: record.stringValue(for: "fertilizerLevel", default: "medium"),
            localizedContents: Self.localizedContents(from: record)
        )
    }

    func update(from record: CKRecord) {
        catalogID = Self.catalogID(from: record)
        species = record.stringValue(for: "species")
        commonName = record.stringValue(for: "commonName")
        overview = record.stringValue(for: "overview")
        imageURL = Self.imageURL(from: record)
        careDifficulty = Self.normalizedCareDifficulty(record.stringValue(for: "careDifficulty", default: "moderate"))
        lightLevel = Self.normalizedLevel(record.stringValue(for: "lightLevel", default: "medium"))
        waterLevel = Self.normalizedLevel(record.stringValue(for: "waterLevel", default: "medium"))
        humidityLevel = Self.normalizedLevel(record.stringValue(for: "humidityLevel", default: "medium"))
        temperature = record.stringValue(for: "temperature")
        diseaseRiskLevel = Self.normalizedLevel(record.stringValue(for: "diseaseRiskLevel", default: "medium"))
        fertilizerLevel = Self.normalizedLevel(record.stringValue(for: "fertilizerLevel", default: "medium"))
        localizedContentsJSON = Self.encodedLocalizedContents(Self.localizedContents(from: record))
    }

    var id: String {
        catalogID
    }

    var localizedContents: [String: PlantInformationLocalizedContent] {
        get {
            Self.decodedLocalizedContents(from: localizedContentsJSON)
        }
        set {
            localizedContentsJSON = Self.encodedLocalizedContents(newValue)
        }
    }

    var displayCommonName: String {
        localizedValue(\.commonName, fallback: commonName)
    }

    var displayOverview: String {
        let fallback: String
        if overview.isEmpty {
            fallback = "\(commonName) is a popular houseplant in the \(species) family. It does best when its light, water, and temperature stay consistent."
        } else {
            fallback = overview
        }

        return localizedValue(\.overview, fallback: fallback)
    }

    var displayTips: String {
        localizedValue(\.tips, fallback: "")
    }

    var careDifficultyDetail: String {
        Self.careDifficultyDetail(for: careDifficulty)
    }

    var lightDetail: String {
        Self.lightDetail(for: lightLevel)
    }

    var waterDetail: String {
        Self.waterDetail(for: waterLevel)
    }

    var humidityDetail: String {
        Self.humidityDetail(for: humidityLevel)
    }

    var diseaseRiskDetail: String {
        Self.diseaseRiskDetail(for: diseaseRiskLevel)
    }

    var fertilizerDetail: String {
        Self.fertilizerDetail(for: fertilizerLevel)
    }

    static func careDifficultyDetail(for level: String) -> String {
        switch level {
        case "easy":
            String(localized: "Easy care. A good fit for beginners and flexible routines.")
        case "hard":
            String(localized: "Needs steady care and closer attention to changes.")
        default:
            String(localized: "Moderate care. Keep light, water, and timing consistent.")
        }
    }

    static func lightDetail(for level: String) -> String {
        switch level {
        case "low":
            String(localized: "Tolerates lower indirect light.")
        case "high":
            String(localized: "Prefers very bright indirect light or gentle direct sun.")
        default:
            String(localized: "Prefers bright indirect light.")
        }
    }

    static func waterDetail(for level: String) -> String {
        switch level {
        case "low":
            String(localized: "Let the soil dry well between waterings.")
        case "high":
            String(localized: "Keep the soil lightly moist and check it often.")
        default:
            String(localized: "Water when the top layer of soil dries.")
        }
    }

    static func humidityDetail(for level: String) -> String {
        switch level {
        case "low":
            String(localized: "Average dry indoor air is usually fine.")
        case "high":
            String(localized: "Prefers higher humidity and benefits from added moisture.")
        default:
            String(localized: "Comfortable with moderate indoor humidity.")
        }
    }

    static func diseaseRiskDetail(for level: String) -> String {
        switch level {
        case "low":
            String(localized: "Low risk. Check occasionally during routine care.")
        case "high":
            String(localized: "Higher risk. Watch leaves, roots, and soil closely.")
        default:
            String(localized: "Moderate risk. Check for early stress signs regularly.")
        }
    }

    static func fertilizerDetail(for level: String) -> String {
        switch level {
        case "low":
            String(localized: "Feed lightly during active growth.")
        case "high":
            String(localized: "Feed more regularly during active growth.")
        default:
            String(localized: "Feed monthly during the growing season.")
        }
    }

    func matchesSearchText(_ searchText: String) -> Bool {
        [
            displayCommonName,
            commonName,
            species
        ]
        .contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
}

private extension PlantInformation {
    static func imageURL(from record: CKRecord) -> URL? {
        guard let url = URL(string: record.stringValue(for: "imageURL")),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else {
            return nil
        }

        return url
    }

    static func localizedContents(from record: CKRecord) -> [String: PlantInformationLocalizedContent] {
        decodedLocalizedContents(from: record.stringValue(for: "localizedContentsJSON", default: "{}"))
    }

    static func catalogID(commonName: String, species: String) -> String {
        let source = species.isEmpty ? commonName : species
        let folded = source.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
        let parts = folded
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }

        return parts.joined(separator: "-").lowercased()
    }

    static func nonEmpty(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    func localizedValue(
        _ keyPath: KeyPath<PlantInformationLocalizedContent, String?>,
        fallback: String
    ) -> String {
        for key in Self.preferredLocalizationKeys() {
            if let value = Self.nonEmpty(localizedContents[key]?[keyPath: keyPath]) {
                return value
            }
        }

        return fallback
    }

    static func preferredLocalizationKeys() -> [String] {
        var keys: [String] = []
        for identifier in Locale.preferredLanguages {
            let normalized = identifier.replacingOccurrences(of: "_", with: "-")
            appendLocalizationKey(normalized, to: &keys)

            var parts = normalized.split(separator: "-").map(String.init)
            while parts.count > 1 {
                parts.removeLast()
                appendLocalizationKey(parts.joined(separator: "-"), to: &keys)
            }
        }

        if let languageCode = Locale.current.language.languageCode?.identifier {
            appendLocalizationKey(languageCode, to: &keys)
        }

        appendLocalizationKey("en", to: &keys)
        return keys
    }

    static func appendLocalizationKey(_ key: String, to keys: inout [String]) {
        guard !key.isEmpty, !keys.contains(key) else { return }
        keys.append(key)
    }

    static func decodedLocalizedContents(from json: String) -> [String: PlantInformationLocalizedContent] {
        guard let data = json.data(using: .utf8),
              let contents = try? JSONDecoder().decode([String: PlantInformationLocalizedContent].self, from: data) else {
            return [:]
        }

        return contents
    }

    static func encodedLocalizedContents(_ contents: [String: PlantInformationLocalizedContent]) -> String {
        guard !contents.isEmpty,
              let data = try? JSONEncoder().encode(contents),
              let json = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        return json
    }

    static func normalizedCareDifficulty(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "easy", "moderate", "hard":
            return normalized
        default:
            return "moderate"
        }
    }

    static func normalizedLevel(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "low", "medium", "high":
            return normalized
        default:
            return "medium"
        }
    }
}

private extension CKRecord {
    nonisolated func stringValue(for key: String, default defaultValue: String = "") -> String {
        guard let value = self[key] as? String else { return defaultValue }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultValue : trimmed
    }
}
