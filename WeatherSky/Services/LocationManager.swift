//
//  LocationManager.swift
//  WeatherSky
//

import CoreLocation
import Foundation

/// Tracks the user's location. "Always" authorization plus significant-location-change monitoring
/// lets iOS relaunch the app in the background when the user moves, which is the most reliable
/// trigger we have for re-checking alerts without a push server.
@MainActor
final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()

    @Published private(set) var authorization: CLAuthorizationStatus
    /// Called whenever a new location fix arrives.
    var onUpdate: (() -> Void)?

    private let manager = CLLocationManager()
    private let latKey = "lastLatitude"
    private let lonKey = "lastLongitude"

    private override init() {
        authorization = .notDetermined
        super.init()
        authorization = manager.authorizationStatus
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
        manager.pausesLocationUpdatesAutomatically = true
        startIfAuthorized()
    }

    /// Last known coordinate, persisted so background launches can use it immediately.
    var savedCoordinate: CLLocationCoordinate2D? {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: latKey) != nil, defaults.object(forKey: lonKey) != nil else {
            return nil
        }
        return CLLocationCoordinate2D(latitude: defaults.double(forKey: latKey),
                                      longitude: defaults.double(forKey: lonKey))
    }

    func requestAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // Upgrade so alerts keep working while the app isn't open.
            manager.requestAlwaysAuthorization()
        default:
            break
        }
    }

    private func startIfAuthorized() {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            manager.startMonitoringSignificantLocationChanges()
            manager.requestLocation()
        case .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }

    private func save(latitude: Double, longitude: Double) {
        UserDefaults.standard.set(latitude, forKey: latKey)
        UserDefaults.standard.set(longitude, forKey: lonKey)
        onUpdate?()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorization = status
            self.startIfAuthorized()
            // Step from "While Using" to "Always" right after the first grant.
            if status == .authorizedWhenInUse {
                self.manager.requestAlwaysAuthorization()
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        Task { @MainActor in
            self.save(latitude: latitude, longitude: longitude)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient failures are fine; we keep using the last saved coordinate.
    }
}
