import Foundation
import SwiftData

@Model
final class PlantInformation {
    var species: String = ""  // 学名
    var commonName: String = ""
    var overview: String = ""
    var photoURL: String?         // 参考图片，指向 Wikipedia 等来源
    var light: String = ""
    var water: String = ""
    var temperature: String = ""
    var fertilizer: String = ""
    var tips: String = ""

    @Relationship(deleteRule: .nullify)
    var plants: [Plant]?

    init(
        species: String,
        commonName: String,
        overview: String = "",
        photoURL: String? = nil,
        light: String,
        water: String,
        temperature: String,
        fertilizer: String,
        tips: String
    ) {
        self.species = species
        self.commonName = commonName
        self.overview = overview
        self.photoURL = photoURL
        self.light = light
        self.water = water
        self.temperature = temperature
        self.fertilizer = fertilizer
        self.tips = tips
    }
}

// MARK: - 内置植物目录（用于首次启动时预填充数据库）

extension PlantInformation {
    var displayOverview: String {
        if !overview.isEmpty {
            return overview
        }

        return "\(commonName) is a popular houseplant in the \(species) family. It does best when its light, water, and temperature stay consistent."
    }

    static var catalog: [PlantInformation] {
        [
        PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "Monstera is a tropical climbing plant loved for its large split leaves. It grows quickly indoors when it has bright filtered light and steady humidity.",
            light: "Bright indirect light, avoid direct sun",
            water: "Water every 7–10 days, let the top inch of soil dry out first",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Fertilize monthly during growing season, stop in winter",
            tips: "Yellowing leaves usually mean overwatering; ensure good air circulation"
        ),
        PlantInformation(
            species: "Epipremnum aureum",
            commonName: "Golden Pothos",
            overview: "Golden Pothos is one of the easiest trailing houseplants for beginners. It tolerates a range of indoor conditions and recovers quickly from small care mistakes.",
            light: "Tolerates low light; avoid strong direct sun",
            water: "Water every 5–7 days, water thoroughly once soil dries out",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Fertilize every 2 weeks in spring and summer",
            tips: "Very adaptable — great for beginners; leaves help purify indoor air"
        ),
        PlantInformation(
            species: "Echeveria",
            commonName: "Echeveria Succulent",
            overview: "Echeveria forms sculptural rosettes and stores water in thick leaves. It needs strong light and a dry soil cycle to keep its compact shape and color.",
            light: "Plenty of sunlight — at least 4–6 hours of direct light daily",
            water: "Water every 10–14 days, let soil dry out completely; avoid waterlogging",
            temperature: "10–35°C (50–95°F)",
            fertilizer: "Apply a diluted fertilizer once a month during growing season",
            tips: "When in doubt, underwater — soggy soil is a succulent's biggest enemy"
        ),
        PlantInformation(
            species: "Sansevieria trifasciata",
            commonName: "Snake Plant",
            overview: "Snake Plant is a resilient upright plant that handles drought, shade, and irregular routines better than most indoor plants. It is a strong choice for bedrooms and offices.",
            light: "Tolerates shade and drought; thrives in indirect to direct light",
            water: "Water every 2–3 weeks; reduce to once a month in winter",
            temperature: "15–35°C (59–95°F)",
            fertilizer: "Fertilize every 2 months during growing season",
            tips: "Extremely low-maintenance; releases oxygen at night — great for bedrooms"
        ),
        PlantInformation(
            species: "Pachira aquatica",
            commonName: "Money Tree",
            light: "Bright indirect light, avoid intense direct sun",
            water: "Water every 7–10 days; increase slightly in summer",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Fertilize once a month during growing season",
            tips: "A symbol of good luck and prosperity — popular in offices and homes"
        ),
        PlantInformation(
            species: "Ficus lyrata",
            commonName: "Fiddle-Leaf Fig",
            light: "Bright indirect light, avoid direct sun",
            water: "Water every 7–10 days once the top 2 cm of soil dries out",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Fertilize once a month during growing season",
            tips: "Dislikes being moved — once you find the right spot, leave it there"
        ),
        PlantInformation(
            species: "Spathiphyllum",
            commonName: "Peace Lily",
            light: "Tolerates low light; avoid strong direct sun",
            water: "Keep soil moist; water every 5–7 days",
            temperature: "18–27°C (64–81°F)",
            fertilizer: "Fertilize every 6 weeks",
            tips: "Drooping leaves are a clear sign it needs water — easy to read"
        ),
        PlantInformation(
            species: "Aloe vera",
            commonName: "Aloe Vera",
            light: "Plenty of sunlight — 4–8 hours of direct light daily",
            water: "Water every 2–3 weeks; reduce in winter; avoid waterlogging",
            temperature: "15–35°C (59–95°F)",
            fertilizer: "Fertilize once every 3 months; less is more",
            tips: "The gel soothes skin burns and irritations — a natural first-aid plant"
        ),
        PlantInformation(
            species: "Pothos",
            commonName: "Pothos",
            light: "Tolerates low light; grows best in bright indirect light",
            water: "Water every 7–10 days, once soil dries out",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Fertilize once a month",
            tips: "Can grow in water — one of the easiest indoor plants to keep alive"
        ),
        PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            light: "Lots of direct sunlight — full sun is ideal",
            water: "Water every 2–4 weeks; reduce to once a month during winter dormancy",
            temperature: "15–40°C (59–104°F)",
            fertilizer: "Apply a diluted cactus fertilizer once a month during growing season",
            tips: "The most drought-tolerant plant — overwatering is the most common mistake"
        ),
        PlantInformation(
            species: "Ficus elastica",
            commonName: "Rubber Plant",
            light: "Bright indirect light; avoid low-light conditions",
            water: "Water every 7–10 days; reduce in winter",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Fertilize once a month during growing season",
            tips: "Large, glossy leaves — wipe them down with a damp cloth regularly"
        ),
        PlantInformation(
            species: "Zamioculcas zamiifolia",
            commonName: "ZZ Plant",
            light: "Tolerates low light; indirect light is best; avoid strong direct sun",
            water: "Water every 2–3 weeks; rhizomes store water well",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Fertilize every 3 months",
            tips: "Nearly indestructible — can survive weeks of neglect; perfect for busy people"
        ),
        PlantInformation(
            species: "Dracaena",
            commonName: "Dracaena",
            light: "Tolerates indirect to low light",
            water: "Water every 7–14 days; avoid overwatering",
            temperature: "18–27°C (64–81°F)",
            fertilizer: "Fertilize once a month during growing season",
            tips: "Sensitive to fluoride — use filtered or distilled water when possible"
        ),
        PlantInformation(
            species: "Begonia",
            commonName: "Begonia",
            light: "Bright indirect light; avoid strong direct sun",
            water: "Keep moist; water every 5–7 days",
            temperature: "18–27°C (64–81°F)",
            fertilizer: "Fertilize every 2 weeks while blooming",
            tips: "Wide variety of colors; long-blooming — deadhead regularly to encourage flowers"
        ),
        PlantInformation(
            species: "Lavandula",
            commonName: "Lavender",
            light: "Full sun — at least 6 hours of direct sunlight daily",
            water: "Water every 7–10 days; ensure good drainage; avoid waterlogging",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Apply a slow-release fertilizer once in spring",
            tips: "Delightful fragrance that naturally repels mosquitoes; pruning keeps it tidy"
        ),
        PlantInformation(
            species: "Chlorophytum comosum",
            commonName: "Spider Plant",
            light: "Indirect light; tolerates low light",
            water: "Water every 5–7 days; keep soil moist",
            temperature: "15–30°C (59–86°F)",
            fertilizer: "Fertilize once a month during growing season",
            tips: "Effective at filtering formaldehyde; offshoots can be propagated into new plants"
        ),
        PlantInformation(
            species: "Dracaena sanderiana",
            commonName: "Lucky Bamboo",
            light: "Indirect to low light; avoid strong direct sun",
            water: "Can grow in water — change water regularly; keep moist if soil-grown",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Add a few drops of liquid fertilizer to water monthly",
            tips: "A symbol of good fortune — commonly grown in water; very easy to care for"
        ),
        PlantInformation(
            species: "Anthurium",
            commonName: "Anthurium",
            light: "Bright indirect light; avoid direct sun",
            water: "Water every 5–7 days; keep moist but not waterlogged",
            temperature: "18–28°C (64–82°F)",
            fertilizer: "Fertilize every 2 weeks",
            tips: "Vibrant, long-lasting spathes; high humidity encourages blooming"
        ),
        PlantInformation(
            species: "Pelargonium",
            commonName: "Geranium",
            light: "Full sun — 4–6 hours of direct light daily",
            water: "Water every 5–7 days; let the soil dry out slightly between waterings",
            temperature: "10–25°C (50–77°F)",
            fertilizer: "Fertilize every 2 weeks while blooming",
            tips: "Long blooming season — remove spent flowers regularly to extend it"
        ),
        PlantInformation(
            species: "Phalaenopsis",
            commonName: "Moth Orchid",
            light: "Bright indirect light; avoid direct sun",
            water: "Water every 7–10 days when roots turn white",
            temperature: "18–28°C (64–82°F); cooler nights encourage reblooming",
            fertilizer: "Apply diluted fertilizer every 2 weeks while blooming",
            tips: "Cut the flower spike to a node to encourage a second bloom; roots need airflow"
        ),
        ]
    }
}
