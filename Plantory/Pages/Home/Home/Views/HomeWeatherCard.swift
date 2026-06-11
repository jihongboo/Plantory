import SwiftUI

struct HomeWeatherCard: View {
    @Environment(\.homeWeatherService) private var weatherService
    @State private var viewState: ViewState<HomeWeatherSnapshot>
    
    init(_ initialState: ViewState<HomeWeatherSnapshot>? = nil) {
        _viewState = State(initialValue: initialState ?? .loading)
    }
    
    var body: some View {
        PixelRoundedRectangleCard {
            HStack(spacing: 0) {
                VStack {
                    image
                        .font(.system(size: 36))
                        .frame(width: 52, height: 52)
                    
                    Text("Today")
                        .font(.pixel(.headline))
                    
                    Text(condition)
                        .font(.pixel(.caption))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .padding(.horizontal)
                
                switch viewState {
                case .loading, .loaded:
                    HStack(spacing: 0) {
                        HomeWeatherMetricTile(
                            title: "Temp",
                            value: viewState.value?.temperatureText,
                            systemImage: "thermometer.medium",
                            level: viewState.value?.temperatureLevel
                        )
                        
                        Rectangle()
                            .fill(.brown.opacity(0.4))
                            .frame(width: 3, height: 60)
                        
                        HomeWeatherMetricTile(
                            title: "Humidity",
                            value: viewState.value?.humidityText,
                            systemImage: "humidity.fill",
                            level: viewState.value?.humidityLevel
                        )
                        
                        Rectangle()
                            .fill(.brown.opacity(0.4))
                            .frame(width: 3, height: 60)
                        
                        HomeWeatherMetricTile(
                            title: "UV",
                            value: viewState.value?.uvIndexText,
                            systemImage: "sun.max.fill",
                            level: viewState.value?.uvIndexLevel
                        )
                    }
                case .failed:
                    Button("Show Weather", systemImage: "location.fill") {
                        Task {
                            await loadWeather()
                        }
                    }
                    .buttonStyle(.pixelRoundedRectangle)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .task(loadWeather)
    }
        
}

private struct HomeWeatherMetricTile: View {
    let title: LocalizedStringKey
    let value: String
    let systemImage: String
    let level: HomeWeatherMetricLevel
    
    init(
        title: LocalizedStringKey,
        value: String?,
        systemImage: String,
        level: HomeWeatherMetricLevel?
    ) {
        self.title = title
        self.value = value ?? "00"
        self.systemImage = systemImage
        self.level = level ?? .ideal
    }
    
    var body: some View {
        VStack {
            Label(title, systemImage: systemImage)
                .font(.pixel(.callout))
                .foregroundStyle(level.color)
                .labelIconToTitleSpacing(4)
                .lineLimit(1)
                .minimumScaleFactor(0.2)
            
            Text(value)
                .font(.pixel(.title))
                .foregroundStyle(level.color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(4)
        .frame(maxWidth: .infinity)
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
                .buttonBackground
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
        HomeWeatherCard(.loading)
        HomeWeatherCard(.loaded(.previewComfortable))
        HomeWeatherCard(.failed(AppError.custom("error")))
    }
    .padding()
    .environment(\.locale, Locale(identifier: "en"))
}

private extension HomeWeatherCard {
    @ViewBuilder
    var image: some View {
        switch viewState {
        case .loading:
            ProgressView()
                .controlSize(.large)
        case .loaded(let weather):
            Image(systemName: weather.symbolName)
                .foregroundStyle(.yellow, .blue)
        case .failed:
            Image(systemName: "cloud.sun.fill")
                .foregroundStyle(.yellow, .blue)
        }
    }

    var condition: String {
        switch viewState {
        case .loading:
            "Loading weather"
        case .loaded(let weather):
            weather.condition
        case .failed(let error):
            error.localizedDescription
        }
    }

    func loadWeather() async {
        do {
            viewState = .loaded(try await weatherService.currentWeather())
        } catch {
            viewState = .failed(error)
        }
    }
}
