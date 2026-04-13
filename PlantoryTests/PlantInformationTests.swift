import Testing
@testable import Plantory

struct PlantInformationTests {

    @Test func mergePreferredValuesUsesIncomingRecognizedContent() {
        let existing = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "Monstera is a tropical climbing plant loved for its large split leaves.",
            light: "Bright indirect light, avoid direct sun",
            water: "Water every 7–10 days, let the top inch of soil dry out first",
            temperature: "18–30°C (64–86°F)",
            fertilizer: "Fertilize monthly during growing season, stop in winter",
            tips: "HHHYellowing leaves usually mean overwatering; ensure good air circulation"
        )

        let incoming = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "龟背竹",
            overview: "热门室内观叶植物，叶片带有标志性的孔洞和裂口，造型别致优雅。",
            light: "放置在明亮散射光处，避免正午强光直射暴晒。",
            water: "待土壤表层 2 至 3 厘米干透后再一次性浇透，避免积水。",
            temperature: "18 至 30 摄氏度，冬季注意防冻，不能低于 5 摄氏度。",
            fertilizer: "春夏生长期每月施加一次稀薄的观叶植物专用肥即可。",
            tips: "定期擦拭叶片保持洁净，能提升光合效率，让叶片更有光泽。"
        )

        existing.mergePreferredValues(from: incoming)

        #expect(existing.commonName == "龟背竹")
        #expect(existing.overview == "热门室内观叶植物，叶片带有标志性的孔洞和裂口，造型别致优雅。")
        #expect(existing.light == "放置在明亮散射光处，避免正午强光直射暴晒。")
        #expect(existing.tips == "定期擦拭叶片保持洁净，能提升光合效率，让叶片更有光泽。")
    }

    @Test func mergePreferredValuesKeepsExistingWhenIncomingFieldIsEmpty() {
        let existing = PlantInformation(
            species: "Monstera deliciosa",
            commonName: "Monstera",
            overview: "Existing overview",
            light: "Existing light",
            water: "Existing water",
            temperature: "Existing temperature",
            fertilizer: "Existing fertilizer",
            tips: "Existing tips"
        )

        let incoming = PlantInformation(
            species: "Monstera deliciosa",
            commonName: " ",
            overview: "",
            light: "",
            water: "",
            temperature: "",
            fertilizer: "",
            tips: ""
        )

        existing.mergePreferredValues(from: incoming)

        #expect(existing.commonName == "Monstera")
        #expect(existing.overview == "Existing overview")
        #expect(existing.light == "Existing light")
        #expect(existing.tips == "Existing tips")
    }
}
