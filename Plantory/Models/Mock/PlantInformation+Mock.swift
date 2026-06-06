import Foundation

@MainActor
extension PlantInformation {
    static let monstera = PlantInformation(
        species: "Monstera deliciosa",
        commonName: "Monstera",
        commonNameZhHans: "龟背竹",
        overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
        overviewZhHans: "龟背竹是热带攀援型观叶植物，喜欢明亮散射光和稳定的室内养护节奏。",
        imageData: PlatformImageData.monstera,
        temperature: "18-30°C",
        tips: "Yellowing leaves = overwatering",
        tipsZhHans: "叶片发黄通常表示浇水过多")
    
    static let succulent = PlantInformation(
        species: "Echeveria elegans",
        commonName: "Succulent",
        commonNameZhHans: "多肉植物",
        overview: "Succulents store water in their leaves and stay compact when they receive strong light and dry soil between waterings.",
        overviewZhHans: "多肉植物会在叶片中储水，在强光和干湿循环明确的环境里更容易保持紧凑株型。",
        imageData: PlatformImageData.succulent,
        lightLevel: "high",
        waterLevel: "low",
        humidityLevel: "low",
        temperature: "15-28°C",
        fertilizerLevel: "low",
        tips: "Wrinkled leaves often mean thirst; mushy leaves usually mean overwatering",
        tipsZhHans: "叶片发皱多半缺水，叶片发软化水通常是浇水过多")
}
