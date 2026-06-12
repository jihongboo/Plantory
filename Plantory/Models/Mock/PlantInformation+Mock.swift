import Foundation

@MainActor
extension PlantInformation {
    static let monstera = PlantInformation(
        species: "Monstera deliciosa",
        commonName: "Monstera",
        overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
        imageURL: URL(string: "https://gfdywyqwbajcetpywino.supabase.co/storage/v1/object/public/Plantory/monstera-deliciosa.png"),
        temperature: "18-30°C",
        localizedContents: [
            "en": PlantInformationLocalizedContent(
                commonName: "Monstera",
                overview: "Monstera is a tropical climbing plant that thrives in bright filtered light and appreciates a stable indoor routine.",
                tips: "Yellowing leaves = overwatering"
            ),
            "zh-Hans": PlantInformationLocalizedContent(
                commonName: "龟背竹",
                overview: "龟背竹是热带攀援型观叶植物，喜欢明亮散射光和稳定的室内养护节奏。",
                tips: "叶片发黄通常表示浇水过多"
            )
        ])
    
    static let succulent = PlantInformation(
        species: "Echeveria elegans",
        commonName: "Succulent",
        overview: "Succulents store water in their leaves and stay compact when they receive strong light and dry soil between waterings.",
        imageURL: URL(string: "https://gfdywyqwbajcetpywino.supabase.co/storage/v1/object/public/Plantory/echeveria-elegans.png"),
        lightLevel: "high",
        waterLevel: "low",
        humidityLevel: "low",
        temperature: "15-28°C",
        fertilizerLevel: "low",
        localizedContents: [
            "en": PlantInformationLocalizedContent(
                commonName: "Succulent",
                overview: "Succulents store water in their leaves and stay compact when they receive strong light and dry soil between waterings.",
                tips: "Wrinkled leaves often mean thirst; mushy leaves usually mean overwatering"
            ),
            "zh-Hans": PlantInformationLocalizedContent(
                commonName: "多肉植物",
                overview: "多肉植物会在叶片中储水，在强光和干湿循环明确的环境里更容易保持紧凑株型。",
                tips: "叶片发皱多半缺水，叶片发软化水通常是浇水过多"
            )
        ])
}
