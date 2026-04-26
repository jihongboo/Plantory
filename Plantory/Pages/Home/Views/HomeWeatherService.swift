import CoreLocation
import Foundation
import WeatherKit

struct HomeWeatherSnapshot: Equatable {
    var temperature: Measurement<UnitTemperature>
    var apparentTemperature: Measurement<UnitTemperature>
    var humidity: Double
    var uvIndex: Int
    var symbolName: String
    var condition: String
}

@MainActor
final class HomeWeatherService: NSObject, CLLocationManagerDelegate {
    static let shared = HomeWeatherService()

    private let locationManager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    var hasLocationAuthorization: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse ||
            locationManager.authorizationStatus == .authorizedAlways
    }

    func currentWeather() async throws -> HomeWeatherSnapshot {
        let location = try await currentLocation()
        let weather: Weather
        do {
            weather = try await WeatherService.shared.weather(for: location)
        } catch {
            throw HomeWeatherServiceError.normalized(error)
        }
        let current = weather.currentWeather

        return HomeWeatherSnapshot(
            temperature: current.temperature,
            apparentTemperature: current.apparentTemperature,
            humidity: current.humidity,
            uvIndex: current.uvIndex.value,
            symbolName: current.symbolName,
            condition: String(describing: current.condition)
        )
    }

    private func currentLocation() async throws -> CLLocation {
        if locationManager.authorizationStatus == .notDetermined {
            try await requestLocationAuthorization()
        }

        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            throw HomeWeatherServiceError.locationDenied
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation?.resume(throwing: HomeWeatherServiceError.locationUnavailable)
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    private func requestLocationAuthorization() async throws {
        try await withCheckedThrowingContinuation { continuation in
            authorizationContinuation?.resume(throwing: HomeWeatherServiceError.locationUnavailable)
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let authorizationContinuation else { return }

        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.authorizationContinuation = nil
            authorizationContinuation.resume()
        case .denied, .restricted:
            self.authorizationContinuation = nil
            authorizationContinuation.resume(throwing: HomeWeatherServiceError.locationDenied)
        case .notDetermined:
            break
        @unknown default:
            self.authorizationContinuation = nil
            authorizationContinuation.resume(throwing: HomeWeatherServiceError.locationUnavailable)
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationContinuation?.resume(returning: location)
        locationContinuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
    }
}

enum HomeWeatherServiceError: LocalizedError {
    case locationDenied
    case locationUnavailable
    case weatherKitAuthenticationFailed

    var errorDescription: String? {
        switch self {
        case .locationDenied:
            String(localized: "Location access is needed for today's weather.")
        case .locationUnavailable:
            String(localized: "Weather is unavailable right now.")
        case .weatherKitAuthenticationFailed:
#if DEBUG
            String(localized: "WeatherKit authentication failed. Enable the WeatherKit capability for this app identifier and refresh the provisioning profile.")
#else
            String(localized: "Weather is unavailable right now.")
#endif
        }
    }

    static func normalized(_ error: Error) -> Error {
        let nsError = error as NSError
        if nsError.domain.contains("WDSJWTAuthenticatorServiceListener") ||
            nsError.localizedDescription.contains("WDSJWTAuthenticatorServiceListener") {
            return HomeWeatherServiceError.weatherKitAuthenticationFailed
        }

        return error
    }
}
