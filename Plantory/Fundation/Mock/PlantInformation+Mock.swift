import Foundation

extension PlantInformation {
    static var monstera: PlantInformation {
        PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
            light: "Bright indirect light",
            water: "Every 7-10 days",
            temperature: "18-30°C",
            fertilizer: "Monthly in growing season",
            tips: "Yellowing leaves = overwatering"
        )
    }

    static var goldenPothos: PlantInformation {
        PlantInformation(
            species: "Epipremnum aureum",
            commonName: "Golden Pothos",
            overview: "Golden Pothos is an adaptable trailing houseplant that stays forgiving for first-time plant owners.",
            light: "Tolerates low light",
            water: "Every 5-7 days",
            temperature: "15-30°C",
            fertilizer: "Every 2 weeks in spring/summer",
            tips: "Great for beginners"
        )
    }

    static var cactus: PlantInformation {
        PlantInformation(
            species: "Cactus",
            commonName: "Cactus",
            overview: "Cactus stores water in its stems and prefers a bright, dry environment with long gaps between watering.",
            light: "Full sun",
            water: "Every 2-4 weeks",
            temperature: "15-40°C",
            fertilizer: "Monthly diluted cactus fertilizer",
            tips: "Overwatering is the most common mistake"
        )
    }
}
