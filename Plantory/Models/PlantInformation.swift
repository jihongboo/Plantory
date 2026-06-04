import Foundation
import SwiftData

@Model
final class PlantInformation {
    var species: String = ""  // 学名
    var commonName: String = ""
    var overview: String = ""
    var photoURL: String?         // 参考图片，指向 Wikipedia 等来源
    var careDifficulty: String = "moderate"
    var careDifficultyDescription: String = ""
    var lightLevel: String = "medium"
    var light: String = ""
    var waterLevel: String = "medium"
    var water: String = ""
    var humidityLevel: String = "medium"
    var humidityDescription: String = ""
    var temperature: String = ""
    var diseaseRiskLevel: String = "medium"
    var diseaseRiskDescription: String = ""
    var fertilizerLevel: String = "medium"
    var fertilizer: String = ""
    var tips: String = ""

    @Relationship(deleteRule: .nullify)
    var plants: [Plant]?

    init(
        species: String,
        commonName: String,
        overview: String = "",
        photoURL: String? = nil,
        careDifficulty: String = "moderate",
        careDifficultyDescription: String = "",
        lightLevel: String = "medium",
        light: String,
        waterLevel: String = "medium",
        water: String,
        humidityLevel: String = "medium",
        humidityDescription: String = "",
        temperature: String,
        diseaseRiskLevel: String = "medium",
        diseaseRiskDescription: String = "",
        fertilizerLevel: String? = nil,
        fertilizer: String,
        tips: String
    ) {
        self.species = species
        self.commonName = commonName
        self.overview = overview
        self.photoURL = photoURL
        self.careDifficulty = careDifficulty
        self.careDifficultyDescription = careDifficultyDescription
        self.lightLevel = lightLevel
        self.light = light
        self.waterLevel = waterLevel
        self.water = water
        self.humidityLevel = humidityLevel
        self.humidityDescription = humidityDescription
        self.temperature = temperature
        self.diseaseRiskLevel = diseaseRiskLevel
        self.diseaseRiskDescription = diseaseRiskDescription
        self.fertilizerLevel = Self.normalizedFertilizerLevel(
            fertilizerLevel ?? Self.inferredFertilizerLevel(from: fertilizer)
        )
        self.fertilizer = fertilizer
        self.tips = tips
    }

    private static func normalizedFertilizerLevel(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "low", "medium", "high":
            return normalized
        default:
            return "medium"
        }
    }

    private static func inferredFertilizerLevel(from fertilizer: String) -> String {
        let lowercased = fertilizer.lowercased()

        if lowercased.contains("less is more")
            || lowercased.contains("once in spring")
            || lowercased.contains("every 3 months")
            || lowercased.contains("every three months")
            || lowercased.contains("every 2 months")
            || lowercased.contains("every two months")
            || lowercased.contains("slow-release")
        {
            return "low"
        }

        if lowercased.contains("every 2 weeks")
            || lowercased.contains("every two weeks")
            || lowercased.contains("biweekly")
        {
            return "high"
        }

        return "medium"
    }
}

// MARK: - 内置植物目录（用于首次启动时预填充数据库）

extension PlantInformation {
    func mergePreferredValues(from incoming: PlantInformation) {
        species = Self.preferredValue(incoming.species, fallback: species)
        commonName = Self.preferredValue(incoming.commonName, fallback: commonName)
        overview = Self.preferredValue(incoming.overview, fallback: overview)
        photoURL = Self.preferredOptionalValue(incoming.photoURL, fallback: photoURL)
        careDifficulty = Self.preferredValue(incoming.careDifficulty, fallback: careDifficulty)
        careDifficultyDescription = Self.preferredValue(
            incoming.careDifficultyDescription,
            fallback: careDifficultyDescription
        )
        lightLevel = Self.preferredValue(incoming.lightLevel, fallback: lightLevel)
        light = Self.preferredValue(incoming.light, fallback: light)
        waterLevel = Self.preferredValue(incoming.waterLevel, fallback: waterLevel)
        water = Self.preferredValue(incoming.water, fallback: water)
        humidityLevel = Self.preferredValue(incoming.humidityLevel, fallback: humidityLevel)
        humidityDescription = Self.preferredValue(
            incoming.humidityDescription,
            fallback: humidityDescription
        )
        temperature = Self.preferredValue(incoming.temperature, fallback: temperature)
        diseaseRiskLevel = Self.preferredValue(incoming.diseaseRiskLevel, fallback: diseaseRiskLevel)
        diseaseRiskDescription = Self.preferredValue(
            incoming.diseaseRiskDescription,
            fallback: diseaseRiskDescription
        )
        fertilizerLevel = Self.normalizedFertilizerLevel(
            Self.preferredValue(incoming.fertilizerLevel, fallback: fertilizerLevel)
        )
        fertilizer = Self.preferredValue(incoming.fertilizer, fallback: fertilizer)
        tips = Self.preferredValue(incoming.tips, fallback: tips)
    }

    private static func preferredValue(_ primary: String, fallback: String) -> String {
        let trimmedPrimary = primary.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedPrimary.isEmpty ? fallback : trimmedPrimary
    }

    private static func preferredOptionalValue(_ primary: String?, fallback: String?) -> String? {
        guard let primary else { return fallback }
        let trimmedPrimary = primary.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedPrimary.isEmpty ? fallback : trimmedPrimary
    }

//    var careDifficultyTitle: String {
//        switch careDifficulty {
//        case "easy":
//            "Easy"
//        case "hard":
//            "Hard"
//        default:
//            "Moderate"
//        }
//    }
//
    var displayOverview: String {
        if !overview.isEmpty {
            return overview
        }

        return "\(commonName) is a popular houseplant in the \(species) family. It does best when its light, water, and temperature stay consistent."
    }
}
