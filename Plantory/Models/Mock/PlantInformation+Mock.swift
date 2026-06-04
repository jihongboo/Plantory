import Foundation

@MainActor
extension PlantInformation {
    static let monstera = PlantInformation(
        species: "Monstera deliciosa",
        commonName: "Monstera",
        overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
        light: "Bright indirect light",
        water: "Every 7-10 days",
        temperature: "18-30°C",
        fertilizer: "Monthly in growing season",
        tips: "Yellowing leaves = overwatering")
    
    static let succulent = PlantInformation(
        species: "Echeveria elegans",
        commonName: "Succulent",
        overview: "Succulents store water in their leaves and stay compact when they receive strong light and dry soil between waterings.",
        light: "Bright light with some direct sun",
        water: "Every 2-3 weeks",
        temperature: "15-28°C",
        fertilizer: "Once in spring with diluted succulent fertilizer",
        tips: "Wrinkled leaves often mean thirst; mushy leaves usually mean overwatering")
}
