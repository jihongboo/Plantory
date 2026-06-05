import SwiftUI

struct PlantInformationCareGuide: View {
    let info: PlantInformation

    private let careColumns = [
        GridItem(.adaptive(minimum: 152), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: careColumns, alignment: .leading, spacing: 12) {
            PixelCareTile(
                title: "Difficulty",
                systemImage: "figure.child",
                tint: difficultyColor,
                indicator: .level(difficultyMeterLevel(info.careDifficulty)),
                detail: info.careDifficultyDescription
            )

            PixelCareTile(
                title: "Light",
                systemImage: "sun.max.fill",
                tint: .pixelSun,
                indicator: .level(meterLevel(info.lightLevel)),
                detail: info.light
            )

            PixelCareTile(
                title: "Water",
                systemImage: "drop.fill",
                tint: .pixelWater,
                indicator: .level(meterLevel(info.waterLevel)),
                detail: info.water
            )

            PixelCareTile(
                title: "Humidity",
                systemImage: "humidity.fill",
                tint: .pixelWater,
                indicator: .level(meterLevel(info.humidityLevel)),
                detail: info.humidityDescription
            )

            PixelCareTile(
                title: "Temperature",
                systemImage: "thermometer.medium",
                tint: .pixelSun,
                indicator: .temperature(activeBands: temperatureBands(info.temperature)),
                detail: info.temperature
            )

            PixelCareTile(
                title: "Fertilizer",
                systemImage: "leaf.circle.fill",
                tint: .pixelLeaf,
                indicator: .level(meterLevel(info.fertilizerLevel)),
                detail: info.fertilizer
            )

            PixelCareTile(
                title: "Disease Risk",
                systemImage: "cross.case.fill",
                tint: diseaseRiskColor(info.diseaseRiskLevel),
                indicator: .level(meterLevel(info.diseaseRiskLevel)),
                detail: info.diseaseRiskDescription
            )
        }
    }

}

#Preview {
    ScrollView {
        PlantInformationCareGuide(info: .monstera)
            .padding()
    }
    .background(.pixelPaper)
}

private extension PlantInformationCareGuide {
    func meterLevel(_ value: String) -> Int {
        switch value {
        case "low":
            1
        case "high":
            3
        default:
            2
        }
    }

    func difficultyMeterLevel(_ value: String) -> Int {
        switch value {
        case "easy":
            1
        case "hard":
            3
        default:
            2
        }
    }

    func temperatureBands(_ temperature: String) -> Set<TemperatureBand> {
        guard let range = celsiusRange(from: temperature) else {
            return [.moderate]
        }

        var bands = Set<TemperatureBand>()

        if range.lowerBound <= 15 {
            bands.insert(.cool)
        }
        if range.upperBound >= 30 {
            bands.insert(.warm)
        }
        if range.upperBound > 15, range.lowerBound < 30 {
            bands.insert(.moderate)
        }

        return bands.isEmpty ? [.moderate] : bands
    }

    func celsiusRange(from temperature: String) -> ClosedRange<Double>? {
        let matches = temperature.matches(of: /-?\d+(\.\d+)?/).compactMap {
            Double($0.0)
        }

        guard !matches.isEmpty else {
            return nil
        }

        let normalized: [Double]
        if temperature.localizedCaseInsensitiveContains("°F") {
            normalized = matches.map { ($0 - 32) * 5 / 9 }
        } else {
            normalized = matches
        }

        guard let minimum = normalized.min(), let maximum = normalized.max() else {
            return nil
        }

        return minimum ... maximum
    }

    var difficultyColor: Color {
        switch info.careDifficulty {
        case "easy":
            .pixelLeaf
        case "hard":
            .pixelSun
        default:
            .pixelWater
        }
    }

    func diseaseRiskColor(_ value: String) -> Color {
        switch value {
        case "low":
            .pixelLeaf
        case "high":
            .pixelDanger
        default:
            .pixelSun
        }
    }
}
