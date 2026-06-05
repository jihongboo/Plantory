import CloudKit
import Foundation

struct PlantInformation: Identifiable, Hashable {
    var id: String { catalogID }

    var catalogID: String
    var recordName: String?
    var species: String
    var commonName: String
    var overview: String
    var photoURL: String?
    var imageFileName: String
    var imageData: Data?
    var careDifficulty: String
    var careDifficultyDescription: String
    var lightLevel: String
    var light: String
    var waterLevel: String
    var water: String
    var humidityLevel: String
    var humidityDescription: String
    var temperature: String
    var diseaseRiskLevel: String
    var diseaseRiskDescription: String
    var fertilizerLevel: String
    var fertilizer: String
    var tips: String
    var sortOrder: Int
    var isPublished: Bool

    init(
        catalogID: String? = nil,
        recordName: String? = nil,
        species: String,
        commonName: String,
        overview: String = "",
        photoURL: String? = nil,
        imageFileName: String = "",
        imageData: Data? = nil,
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
        tips: String,
        sortOrder: Int = 0,
        isPublished: Bool = true
    ) {
        self.catalogID = catalogID ?? Self.catalogID(commonName: commonName, species: species)
        self.recordName = recordName
        self.species = species
        self.commonName = commonName
        self.overview = overview
        self.photoURL = photoURL
        self.imageFileName = imageFileName
        self.imageData = imageData
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
        self.fertilizerLevel = Self.normalizedLevel(
            fertilizerLevel ?? Self.inferredFertilizerLevel(from: fertilizer)
        )
        self.fertilizer = fertilizer
        self.tips = tips
        self.sortOrder = sortOrder
        self.isPublished = isPublished
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
            recordName: record.recordID.recordName,
            species: species,
            commonName: commonName,
            overview: record.stringValue(for: "overview"),
            photoURL: record.optionalStringValue(for: "photoURL"),
            imageFileName: record.stringValue(for: "imageFileName"),
            imageData: imageData,
            careDifficulty: record.stringValue(for: "careDifficulty", default: "moderate"),
            careDifficultyDescription: record.stringValue(for: "careDifficultyDescription"),
            lightLevel: record.stringValue(for: "lightLevel", default: "medium"),
            light: record.stringValue(for: "light"),
            waterLevel: record.stringValue(for: "waterLevel", default: "medium"),
            water: record.stringValue(for: "water"),
            humidityLevel: record.stringValue(for: "humidityLevel", default: "medium"),
            humidityDescription: record.stringValue(for: "humidityDescription"),
            temperature: record.stringValue(for: "temperature"),
            diseaseRiskLevel: record.stringValue(for: "diseaseRiskLevel", default: "medium"),
            diseaseRiskDescription: record.stringValue(for: "diseaseRiskDescription"),
            fertilizerLevel: record.stringValue(for: "fertilizerLevel", default: "medium"),
            fertilizer: record.stringValue(for: "fertilizer"),
            tips: record.stringValue(for: "tips"),
            sortOrder: record.intValue(for: "sortOrder"),
            isPublished: record.intValue(for: "isPublished") == 1
        )
    }

    var displayOverview: String {
        if !overview.isEmpty {
            return overview
        }

        return "\(commonName) is a popular houseplant in the \(species) family. It does best when its light, water, and temperature stay consistent."
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

    static func normalizedLevel(_ value: String) -> String {
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        switch normalized {
        case "low", "medium", "high":
            return normalized
        default:
            return "medium"
        }
    }

    static func inferredFertilizerLevel(from fertilizer: String) -> String {
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

    func intValue(for key: String) -> Int {
        if let value = self[key] as? Int {
            return value
        }

        if let value = self[key] as? Int64 {
            return Int(value)
        }

        if let value = self[key] as? NSNumber {
            return value.intValue
        }

        return 0
    }
}
