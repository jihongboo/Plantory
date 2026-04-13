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

    static var catalog: PlantInformation {
        PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "Monstera is a tropical climbing plant loved for its large split leaves. It grows quickly indoors when it has bright filtered light and steady humidity.",
            light: "Bright indirect light, avoid direct sun",
            water: "Water every 7–10 days, let the top inch of soil dry out first",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Fertilize monthly during growing season, stop in winter",
            tips: "hahahYellowing leaves usually mean overwatering; ensure good air circulation"
        )
    }
}
