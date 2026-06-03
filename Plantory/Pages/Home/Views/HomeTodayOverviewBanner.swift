import SwiftData
import SwiftUI

struct HomeTodayOverviewBanner: View {
    let plants: [Plant]
    private let initialWeatherState: HomeWeatherState?
    
    init(plants: [Plant]) {
        self.plants = plants
        self.initialWeatherState = nil
    }
    
    fileprivate init(plants: [Plant], weatherState: HomeWeatherState) {
        self.plants = plants
        self.initialWeatherState = weatherState
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HomeWeatherOverviewCard(initialState: initialWeatherState)
            
            HomeCareOverviewCard(plants: plants)
        }
    }
}

private struct HomeWeatherOverviewCard: View {
    @State private var weatherState: HomeWeatherState
    
    init(initialState: HomeWeatherState? = nil) {
        _weatherState = State(initialValue: initialState ?? .idle)
    }
    
    var body: some View {
        weatherContent
            .modifier(PixelCardShell())
            .task {
                await loadWeatherIfAlreadyAuthorized()
            }
    }
    
    @ViewBuilder
    private var weatherContent: some View {
        switch weatherState {
        case .idle:
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(PixelTheme.leaf)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today")
                        .font(.headline)
                    
                    Text("Local weather can help plan watering and feeding.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        Task {
                            await loadWeatherOverview()
                        }
                    } label: {
                        PixelButtonLabel(title: "Show Weather", systemImage: "location.fill")
                    }
                    .buttonStyle(.plain)
                }
            }
            
        case .loading:
            HStack(spacing: 12) {
                ProgressView()
                    .controlSize(.small)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.headline)
                    Text("Loading weather")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
        case .loaded(let weather):
            HStack {
                VStack {
                    Image(systemName: weather.symbolName)
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.yellow, .blue)
                        .padding(.horizontal)
                    
                    Text("Today")
                        .font(.headline)
                    
                    Text(weather.condition)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                HStack {
                    HomeWeatherMetricTile(
                        title: "Temp",
                        value: weather.temperatureText,
                        detail: "Feels \(weather.apparentTemperatureText)",
                        systemImage: "thermometer.medium",
                        level: weather.temperatureLevel
                    )
                    
                    HomeWeatherMetricTile(
                        title: "Humidity",
                        value: weather.humidityText,
                        detail: weather.humidityLevel.summary,
                        systemImage: "humidity.fill",
                        level: weather.humidityLevel
                    )

                    HomeWeatherMetricTile(
                        title: "UV",
                        value: weather.uvIndexText,
                        detail: weather.uvIndexLevel.summary,
                        systemImage: "sun.max.fill",
                        level: weather.uvIndexLevel
                    )
                }
            }
            
        case .unavailable(let message):
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(PixelTheme.sun, PixelTheme.water)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Today")
                        .font(.headline)
                    
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Button {
                        Task {
                            await loadWeatherOverview()
                        }
                    } label: {
                        PixelButtonLabel(title: "Retry", systemImage: "arrow.clockwise", fill: PixelTheme.wood)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func loadWeatherOverview() async {
        guard weatherState != .loading else { return }
        weatherState = .loading
        
        do {
            weatherState = .loaded(try await HomeWeatherService.shared.currentWeather())
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
            ?? String(localized: "Weather is unavailable right now.")
            weatherState = .unavailable(message)
        }
    }
    
    private func loadWeatherIfAlreadyAuthorized() async {
        guard weatherState == .idle,
              HomeWeatherService.shared.hasLocationAuthorization else {
            return
        }
        
        await loadWeatherOverview()
    }
}

private struct HomeCareOverviewCard: View {
    let plants: [Plant]
    
    private var careTasks: [HomeCareTask] {
        plants
            .flatMap { todayCareTasks(for: $0) }
            .sorted { $0.plantName.localizedStandardCompare($1.plantName) == .orderedAscending }
    }
    
    private var wateringCount: Int {
        careTasks.filter { $0.kind == .watering }.count
    }
    
    private var fertilizingCount: Int {
        careTasks.filter { $0.kind == .fertilizing }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Tasks")
                .font(.title3.weight(.black))
                .foregroundStyle(PixelTheme.ink)
            
            HStack(spacing: 8) {
                HomeCareCountPill(
                    count: wateringCount,
                    title: "Water",
                    systemImage: "drop.fill",
                    tint: .blue
                )
                
                HomeCareCountPill(
                    count: fertilizingCount,
                    title: "Feed",
                    systemImage: "leaf.fill",
                    tint: .green
                )
            }
            
            Text(careTasks.isEmpty ? "No care due" : "\(careTasks.count) due today")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PixelTheme.ink.opacity(0.68))
        }
        .modifier(PixelCardShell())
    }
    
    private func todayCareTasks(for plant: Plant) -> [HomeCareTask] {
        guard let settings = plant.notificationSettings else { return [] }
        
        return settings.compactMap { setting in
            guard setting.isEnabled,
                  setting.kind == .watering || setting.kind == .fertilizing,
                  isDueToday(setting, for: plant) else {
                return nil
            }
            
            return HomeCareTask(
                id: "\(plant.persistentModelID)-\(setting.kind.rawValue)",
                plantName: plant.displayName,
                kind: setting.kind
            )
        }
    }
    
    private func isDueToday(_ setting: PlantNotificationSetting, for plant: Plant) -> Bool {
        let latestRecordDate = latestRelevantRecordDate(for: setting.kind, plant: plant)
        if let latestRecordDate,
           Calendar.current.isDate(latestRecordDate, inSameDayAs: .now) {
            return false
        }
        
        let dueDate = nextDueDate(for: setting, plant: plant, latestRecordDate: latestRecordDate)
        let endOfToday = Calendar.current.dateInterval(of: .day, for: .now)?.end ?? .now
        return dueDate < endOfToday
    }
    
    private func nextDueDate(
        for setting: PlantNotificationSetting,
        plant: Plant,
        latestRecordDate: Date?
    ) -> Date {
        let calendar = Calendar.current
        let intervalDays = max(1, setting.intervalDays)
        let referenceDate = latestRecordDate ?? plant.createdAt
        let anchorDate = calendar.date(
            bySettingHour: setting.reminderHour,
            minute: setting.reminderMinute,
            second: 0,
            of: referenceDate
        ) ?? referenceDate
        
        return calendar.date(byAdding: .day, value: intervalDays, to: anchorDate) ?? .now
    }
    
    private func latestRelevantRecordDate(for kind: PlantNotificationKind, plant: Plant) -> Date? {
        let actionType: RecordActionType = switch kind {
        case .watering:
                .watering
        case .fertilizing:
                .fertilizing
        case .pestCheck:
                .pestControl
        case .pruning:
                .pruning
        case .repotting:
                .repotting
        }
        
        return (plant.records ?? [])
            .filter { $0.actionType == actionType }
            .map(\.createdAt)
            .max()
    }
}

private enum HomeWeatherState: Equatable {
    case idle
    case loading
    case loaded(HomeWeatherSnapshot)
    case unavailable(String)
}

private struct HomeCareTask: Identifiable, Hashable {
    var id: String
    var plantName: String
    var kind: PlantNotificationKind
}

private struct HomeCareCountPill: View {
    let count: Int
    let title: LocalizedStringKey
    let systemImage: String
    let tint: Color
    
    var body: some View {
        HStack {
            VStack(spacing: 5) {
                Image(systemName: systemImage)
                    .font(.body.weight(.bold))
                Text(title)
                    .font(.caption2.weight(.semibold))
            }
            Text("\(count)")
                .font(.title.weight(.bold))
        }

        .foregroundStyle(tint)
        .frame(maxWidth: .infinity)
        .padding(8)
        .background(tint.opacity(0.12))
        .clipShape(.rect(cornerRadius: 4))
        .overlay {
            Rectangle()
                .stroke(tint.opacity(0.45), lineWidth: 1.5)
        }
    }
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
                .font(.caption2.weight(.semibold))
                .foregroundStyle(level.color)
                .labelIconToTitleSpacing(4)
            
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(level.color)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(detail)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .background(level.color.opacity(0.12))
        .clipShape(.rect(cornerRadius: 4))
        .overlay {
            Rectangle()
                .stroke(level.color.opacity(0.35), lineWidth: 1.5)
        }
    }
}

private struct PixelCardShell: ViewModifier {
    func body(content: Content) -> some View {
        PixelPanel {
            content
        }
    }
}

private struct HomeWeatherCareHint: Identifiable, Hashable {
    var id: String
    var message: String
    var systemImage: String
    var level: HomeWeatherMetricLevel
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
    
    var careHints: [HomeWeatherCareHint] {
        var hints: [HomeWeatherCareHint] = []
        
        switch temperatureLevel {
        case .extreme where temperatureCelsius < 5:
            hints.append(
                HomeWeatherCareHint(
                    id: "temperature-freezing",
                    message: String(localized: "Temperature is very low. Protect sensitive plants from cold drafts and move them indoors when needed."),
                    systemImage: "snowflake",
                    level: temperatureLevel
                )
            )
        case .low:
            hints.append(
                HomeWeatherCareHint(
                    id: "temperature-low",
                    message: String(localized: "Temperature is low. Keep plants warm and avoid watering with cold soil."),
                    systemImage: "thermometer.low",
                    level: temperatureLevel
                )
            )
        case .high:
            hints.append(
                HomeWeatherCareHint(
                    id: "temperature-high",
                    message: String(localized: "Temperature is high. Check soil moisture more often and keep plants away from harsh afternoon sun."),
                    systemImage: "sun.max.fill",
                    level: temperatureLevel
                )
            )
        case .extreme:
            hints.append(
                HomeWeatherCareHint(
                    id: "temperature-extreme",
                    message: String(localized: "Temperature is extreme. Move plants to a cooler, shaded spot and watch for heat stress."),
                    systemImage: "thermometer.high",
                    level: temperatureLevel
                )
            )
        case .ideal:
            break
        }
        
        switch humidityLevel {
        case .extreme where humidity < 0.25:
            hints.append(
                HomeWeatherCareHint(
                    id: "humidity-very-dry",
                    message: String(localized: "Air is very dry. Consider grouping humidity-loving plants or using a humidifier."),
                    systemImage: "humidity",
                    level: humidityLevel
                )
            )
        case .low:
            hints.append(
                HomeWeatherCareHint(
                    id: "humidity-low",
                    message: String(localized: "Humidity is low. Mist only suitable plants and monitor leaf edges for drying."),
                    systemImage: "drop.triangle",
                    level: humidityLevel
                )
            )
        case .high:
            hints.append(
                HomeWeatherCareHint(
                    id: "humidity-high",
                    message: String(localized: "Humidity is high. Improve airflow and avoid leaving foliage wet for too long."),
                    systemImage: "wind",
                    level: humidityLevel
                )
            )
        case .extreme:
            hints.append(
                HomeWeatherCareHint(
                    id: "humidity-very-high",
                    message: String(localized: "Humidity is very high. Watch for fungal issues and keep leaves dry overnight."),
                    systemImage: "allergens",
                    level: humidityLevel
                )
            )
        case .ideal:
            break
        }

        switch uvIndexLevel {
        case .low:
            hints.append(
                HomeWeatherCareHint(
                    id: "uv-low",
                    message: String(localized: "UV is low today. Bright-light plants may need a brighter window or a grow light."),
                    systemImage: "sun.min",
                    level: uvIndexLevel
                )
            )
        case .high:
            hints.append(
                HomeWeatherCareHint(
                    id: "uv-high",
                    message: String(localized: "UV is high. Keep sensitive plants out of harsh midday direct sun."),
                    systemImage: "sun.max.fill",
                    level: uvIndexLevel
                )
            )
        case .extreme:
            hints.append(
                HomeWeatherCareHint(
                    id: "uv-extreme",
                    message: String(localized: "UV is extreme. Move delicate plants to filtered light and watch for leaf scorch."),
                    systemImage: "sun.max.trianglebadge.exclamationmark",
                    level: uvIndexLevel
                )
            )
        case .ideal:
            break
        }
        
        if hints.isEmpty {
            hints.append(
                HomeWeatherCareHint(
                    id: "weather-comfort",
                    message: String(localized: "Temperature, humidity, and UV look comfortable for most indoor plants today."),
                    systemImage: "checkmark.circle.fill",
                    level: .ideal
                )
            )
        }
        
        return hints
    }
}

#Preview("Weather and Tasks") {
    let plant = Plant(nickname: "Living Room Pothos")
    plant.records = [
        PlantRecord(
            actionType: .watering,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: .now) ?? .now,
            plant: plant
        )
    ]
    plant.notificationSettings = [
        PlantNotificationSetting(
            kind: .watering,
            isEnabled: true,
            intervalDays: 1,
            reminderHour: 9,
            plant: plant
        ),
        PlantNotificationSetting(
            kind: .fertilizing,
            isEnabled: true,
            intervalDays: 1,
            reminderHour: 10,
            plant: plant
        )
    ]
    
    return HomeTodayOverviewBanner(
        plants: [plant],
        weatherState: .loaded(
            HomeWeatherSnapshot(
                temperature: Measurement(value: 24, unit: UnitTemperature.celsius),
                apparentTemperature: Measurement(value: 26, unit: UnitTemperature.celsius),
                humidity: 0.68,
                uvIndex: 4,
                symbolName: "cloud.sun.fill",
                condition: "Partly Cloudy"
            )
        )
    )
    .padding()
}

#Preview("Cold and Dry") {
    HomeTodayOverviewBanner(
        plants: [],
        weatherState: .loaded(
            HomeWeatherSnapshot(
                temperature: Measurement(value: 4, unit: UnitTemperature.celsius),
                apparentTemperature: Measurement(value: 2, unit: UnitTemperature.celsius),
                humidity: 0.22,
                uvIndex: 1,
                symbolName: "snowflake",
                condition: "Cold"
            )
        )
    )
    .padding()
}

#Preview("Hot and Humid") {
    HomeTodayOverviewBanner(
        plants: [],
        weatherState: .loaded(
            HomeWeatherSnapshot(
                temperature: Measurement(value: 36, unit: UnitTemperature.celsius),
                apparentTemperature: Measurement(value: 40, unit: UnitTemperature.celsius),
                humidity: 0.88,
                uvIndex: 9,
                symbolName: "sun.max.fill",
                condition: "Hot"
            )
        )
    )
    .padding()
}
