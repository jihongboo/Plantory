import CloudKit
import Foundation

struct PlantInformation: Identifiable, Hashable {
    var id: String { catalogID }

    var catalogID: String
    var species: String
    var commonName: String
    var commonNameZhHans: String?
    var overview: String
    var overviewZhHans: String?
    var imageData: Data?
    var careDifficulty: String
    var lightLevel: String
    var waterLevel: String
    var humidityLevel: String
    var temperature: String
    var diseaseRiskLevel: String
    var fertilizerLevel: String
    var tips: String
    var tipsZhHans: String?

    init(
        catalogID: String? = nil,
        species: String,
        commonName: String,
        commonNameZhHans: String? = nil,
        overview: String = "",
        overviewZhHans: String? = nil,
        imageData: Data? = nil,
        careDifficulty: String = "moderate",
        lightLevel: String = "medium",
        waterLevel: String = "medium",
        humidityLevel: String = "medium",
        temperature: String,
        diseaseRiskLevel: String = "medium",
        fertilizerLevel: String? = nil,
        tips: String,
        tipsZhHans: String? = nil
    ) {
        self.catalogID = catalogID ?? Self.catalogID(commonName: commonName, species: species)
        self.species = species
        self.commonName = commonName
        self.commonNameZhHans = Self.nonEmpty(commonNameZhHans)
        self.overview = overview
        self.overviewZhHans = Self.nonEmpty(overviewZhHans)
        self.imageData = imageData
        self.careDifficulty = careDifficulty
        self.lightLevel = lightLevel
        self.waterLevel = waterLevel
        self.humidityLevel = humidityLevel
        self.temperature = temperature
        self.diseaseRiskLevel = diseaseRiskLevel
        self.fertilizerLevel = Self.normalizedLevel(fertilizerLevel ?? "medium")
        self.tips = tips
        self.tipsZhHans = Self.nonEmpty(tipsZhHans)
    }
}

extension PlantInformation {
    init(record: CKRecord) {
        let catalogID = record.stringValue(for: "catalogID")
        let species = record.stringValue(for: "species")
        let commonName = record.stringValue(for: "commonName")
        let imageAsset = record["image"] as? CKAsset
        let imageData = imageAsset?.fileURL.flatMap { try? Data(contentsOf: $0) }

        self.init(
            catalogID: catalogID.isEmpty ? record.recordID.recordName : catalogID,
            species: species,
            commonName: commonName,
            commonNameZhHans: record.optionalStringValue(for: "commonNameZhHans"),
            overview: record.stringValue(for: "overview"),
            overviewZhHans: record.optionalStringValue(for: "overviewZhHans"),
            imageData: imageData,
            careDifficulty: record.stringValue(for: "careDifficulty", default: "moderate"),
            lightLevel: record.stringValue(for: "lightLevel", default: "medium"),
            waterLevel: record.stringValue(for: "waterLevel", default: "medium"),
            humidityLevel: record.stringValue(for: "humidityLevel", default: "medium"),
            temperature: record.stringValue(for: "temperature"),
            diseaseRiskLevel: record.stringValue(for: "diseaseRiskLevel", default: "medium"),
            fertilizerLevel: record.stringValue(for: "fertilizerLevel", default: "medium"),
            tips: record.stringValue(for: "tips"),
            tipsZhHans: record.optionalStringValue(for: "tipsZhHans")
        )
    }

    var displayCommonName: String {
        localizedText(zhHans: commonNameZhHans, fallback: commonName)
    }

    var displayOverview: String {
        let fallback: String
        if overview.isEmpty {
            fallback = "\(commonName) is a popular houseplant in the \(species) family. It does best when its light, water, and temperature stay consistent."
        } else {
            fallback = overview
        }

        return localizedText(zhHans: overviewZhHans, fallback: fallback)
    }

    var displayTips: String {
        localizedText(zhHans: tipsZhHans, fallback: tips)
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
            commonNameZhHans,
            species
        ]
        .compactMap { $0 }
        .contains { $0.localizedCaseInsensitiveContains(searchText) }
    }
}

private extension PlantInformation {
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

    func localizedText(zhHans: String?, fallback: String) -> String {
        if Locale.current.language.languageCode?.identifier == "zh",
           let zhHans = Self.nonEmpty(zhHans) {
            return zhHans
        }

        return fallback
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
    func stringValue(for key: String, default defaultValue: String = "") -> String {
        guard let value = self[key] as? String else { return defaultValue }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? defaultValue : trimmed
    }

    func optionalStringValue(for key: String) -> String? {
        let value = stringValue(for: key)
        return value.isEmpty ? nil : value
    }
}
