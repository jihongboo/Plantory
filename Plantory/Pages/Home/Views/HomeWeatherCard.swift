import SwiftUI

struct HomeWeatherCard: View {
    @State private var weatherState: HomeWeatherState
    
    init(initialState: HomeWeatherState? = nil) {
        _weatherState = State(initialValue: initialState ?? .loading)
    }
    
    var body: some View {
        PixelCard {
            HStack {
                VStack {
                    image
                        .font(.system(size: 32, weight: .semibold))
                        .frame(width: 50, height: 50)
                    
                    Text("Today")
                        .font(PixelTheme.font(size: 17, weight: .semibold, relativeTo: .headline))
                    
                    Text(condition)
                        .font(PixelTheme.font(size: 12, relativeTo: .caption))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .containerRelativeFrame(.horizontal, count: 4, spacing: 0)
                
                switch weatherState {
                case .loading:
                    Spacer()
                case .loaded(let weather):
                    HStack {
                        HomeWeatherMetricTile(
                            title: "Temp",
                            value: weather.temperatureText,
                            detail: "Feels \(weather.apparentTemperatureText)",
                            systemImage: "thermometer.medium",
                            level: weather.temperatureLevel
                        )
                        
                        Rectangle()
                            .fill(.brown.opacity(0.4))
                            .frame(width: 3, height: 60)
                        
                        HomeWeatherMetricTile(
                            title: "Humidity",
                            value: weather.humidityText,
                            detail: weather.humidityLevel.summary,
                            systemImage: "humidity.fill",
                            level: weather.humidityLevel
                        )
                        
                        Rectangle()
                            .fill(.brown.opacity(0.4))
                            .frame(width: 3, height: 60)
                        
                        HomeWeatherMetricTile(
                            title: "UV",
                            value: weather.uvIndexText,
                            detail: weather.uvIndexLevel.summary,
                            systemImage: "sun.max.fill",
                            level: weather.uvIndexLevel
                        )
                    }
                case .unavailable:
                    Button("Show Weather", systemImage: "location.fill") {
                        Task {
                            await loadWeatherOverview()
                        }
                    }
                    .buttonStyle(.pixel)
                }
            }
        }
        .task(loadWeatherOverview)
    }
    
    @ViewBuilder
    private var image: some View {
        switch weatherState {
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .loaded(let weather):
            Image(systemName: weather.symbolName)
                .foregroundStyle(.yellow, .blue)
        case .unavailable:
            Image(systemName: "cloud.sun.fill")
                .foregroundStyle(.yellow, .blue)
        }
    }
    
    private var condition: String {
        switch weatherState {
        case .loading:
            "Loading weather"
        case .loaded(let weather):
            weather.condition
        case .unavailable(let string):
            string
        }
    }
    
    private func loadWeatherOverview() async {
        do {
            weatherState = .loaded(try await HomeWeatherService.shared.currentWeather())
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
            ?? String(localized: "Weather is unavailable right now.")
            weatherState = .unavailable(message)
        }
    }
}

enum HomeWeatherState: Equatable {
    case loading
    case loaded(HomeWeatherSnapshot)
    case unavailable(String)
}

private struct HomeWeatherMetricTile: View {
    let title: LocalizedStringKey
    let value: String
    let detail: String
    let systemImage: String
    let level: HomeWeatherMetricLevel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(title, systemImage: systemImage)
                .font(PixelTheme.font(size: 12, weight: .semibold, relativeTo: .caption2))
                .foregroundStyle(level.color)
                .labelIconToTitleSpacing(4)
            
            Text(value)
                .font(PixelTheme.font(size: 20, weight: .bold, relativeTo: .title3))
                .foregroundStyle(level.color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            
            Text(detail)
                .font(PixelTheme.font(size: 12, relativeTo: .caption2))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 78, alignment: .leading)
    }
}

private enum HomeWeatherMetricLevel: Hashable {
    case low
    case ideal
    case high
    case extreme
    
    var color: Color {
        switch self {
        case .low:
                .blue
        case .ideal:
                .green
        case .high:
                .orange
        case .extreme:
                .red
        }
    }
    
    var summary: String {
        switch self {
        case .low:
            String(localized: "Low")
        case .ideal:
            String(localized: "Comfort")
        case .high:
            String(localized: "High")
        case .extreme:
            String(localized: "Extreme")
        }
    }
}

private extension HomeWeatherSnapshot {
    private var temperatureCelsius: Double {
        temperature.converted(to: .celsius).value
    }
    
    var temperatureText: String {
        temperature.formatted(
            .measurement(
                width: .abbreviated,
                usage: .weather,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }
    
    var apparentTemperatureText: String {
        apparentTemperature.formatted(
            .measurement(
                width: .abbreviated,
                usage: .weather,
                numberFormatStyle: .number.precision(.fractionLength(0))
            )
        )
    }
    
    var humidityText: String {
        humidity.formatted(.percent.precision(.fractionLength(0)))
    }
    
    var uvIndexText: String {
        uvIndex.formatted()
    }
    
    var temperatureLevel: HomeWeatherMetricLevel {
        switch temperatureCelsius {
        case ..<5:
                .extreme
        case ..<12:
                .low
        case 12...30:
                .ideal
        case ...35:
                .high
        default:
                .extreme
        }
    }
    
    var humidityLevel: HomeWeatherMetricLevel {
        switch humidity {
        case ..<0.25:
                .extreme
        case ..<0.40:
                .low
        case 0.40...0.75:
                .ideal
        case ...0.85:
                .high
        default:
                .extreme
        }
    }
    
    var uvIndexLevel: HomeWeatherMetricLevel {
        switch uvIndex {
        case ...2:
                .low
        case 3...5:
                .ideal
        case 6...7:
                .high
        default:
                .extreme
        }
    }
}

#Preview {
    VStack {
        HomeWeatherCard(
            initialState: .loading,
        )
        HomeWeatherCard(
            initialState: .loaded(.previewComfortable),
        )
        HomeWeatherCard(
            initialState: .unavailable("Location access is needed for today's weather."),
        )
    }
    .padding()
}

private extension HomeWeatherSnapshot {
    static let previewComfortable = HomeWeatherSnapshot(
        temperature: Measurement(value: 24, unit: UnitTemperature.celsius),
        apparentTemperature: Measurement(value: 26, unit: UnitTemperature.celsius),
        humidity: 0.68,
        uvIndex: 4,
        symbolName: "cloud.sun.fill",
        condition: "Partly Cloudy"
    )
}
