import SwiftUI

struct PlantInfoInformationCard: View {
    let info: PlantInformation

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        CardView(
            title: info.commonName,
            subtitle: info.species,
            systemImage: "leaf.fill",
            iconTint: .green
        ) {
            VStack(alignment: .leading, spacing: 18) {
                overviewBlock
                careGrid
            }
        }
    }

    private var overviewBlock: some View {
        Text(info.displayOverview)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var careGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareTileView(
                title: "Tips",
                icon: "sparkles",
                tint: .pink,
                usesFixedHeight: false,
                detail: info.tips
            )

            LazyVGrid(columns: columns, spacing: 12) {
                CareTileView(
                    title: "Difficulty",
                    icon: "figure.child",
                    indicator: .level(difficultyMeterLevel(info.careDifficulty)),
                    tint: difficultyColor,
                    detail: "Best for \(difficultyAudience(info.careDifficulty)) plant care routines."
                )
                CareTileView(
                    title: "Light",
                    icon: "sun.max",
                    indicator: .level(meterLevel(info.lightLevel)),
                    tint: .yellow,
                    detail: info.light
                )
                CareTileView(
                    title: "Water",
                    icon: "drop",
                    indicator: .level(meterLevel(info.waterLevel)),
                    tint: .blue,
                    detail: info.water
                )
                CareTileView(
                    title: "Humidity",
                    icon: "humidity",
                    indicator: .level(meterLevel(info.humidityLevel)),
                    tint: .mint,
                    detail: humidityDescription(for: info.humidityLevel)
                )
                CareTileView(
                    title: "Temperature",
                    icon: "thermometer",
                    indicator: .temperature(activeBands: temperatureBands(info.temperature)),
                    tint: .orange,
                    detail: info.temperature
                )
                CareTileView(
                    title: "Fertilizer",
                    icon: "leaf.circle",
                    indicator: .level(meterLevel(info.fertilizerLevel)),
                    tint: .green,
                    detail: info.fertilizer
                )
                CareTileView(
                    title: "Disease Risk",
                    icon: "cross.case",
                    indicator: .level(meterLevel(info.diseaseRiskLevel)),
                    tint: diseaseRiskColor(info.diseaseRiskLevel),
                    detail: diseaseRiskDescription(for: info.diseaseRiskLevel)
                )
            }
        }
    }

    private func meterLevel(_ value: String) -> Int {
        switch value {
        case "low":
            1
        case "high":
            3
        default:
            2
        }
    }

    private func difficultyMeterLevel(_ value: String) -> Int {
        switch value {
        case "easy":
            1
        case "hard":
            3
        default:
            2
        }
    }

    private func temperatureBands(_ temperature: String) -> Set<TemperatureBand> {
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

    private func celsiusRange(from temperature: String) -> ClosedRange<Double>? {
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

    private var difficultyColor: Color {
        switch info.careDifficulty {
        case "easy":
            .green
        case "hard":
            .orange
        default:
            .teal
        }
    }

    private func diseaseRiskColor(_ value: String) -> Color {
        switch value {
        case "low":
            .green
        case "high":
            .red
        default:
            .orange
        }
    }

    private func difficultyAudience(_ value: String) -> String {
        switch value {
        case "easy":
            "beginner-friendly"
        case "hard":
            "experienced"
        default:
            "steady"
        }
    }

    private func humidityDescription(for value: String) -> String {
        switch value {
        case "low":
            "Comfortable in drier indoor air with minimal extra humidity."
        case "high":
            "Prefers consistently humid air and benefits from added moisture."
        default:
            "Does best in moderate indoor humidity without large swings."
        }
    }

    private func diseaseRiskDescription(for value: String) -> String {
        switch value {
        case "low":
            "Usually stays stable when watering and airflow remain consistent."
        case "high":
            "Monitor leaves and soil closely because stress symptoms show up faster."
        default:
            "Watch for early stress signs if light, water, or airflow drift off routine."
        }
    }
}

#Preview {
    ScrollView {
        PlantInfoInformationCard(info: AddPlantCardPreviewSupport.plantInformation)
            .padding()
    }
}
