//
//  AlertMonitor.swift
//  WeatherSky
//

import Foundation

/// Fetches alerts for the user's saved location and notifies about new ones. Called from the UI,
/// from location updates, and from background refresh.
@MainActor
final class AlertMonitor: ObservableObject {
    static let shared = AlertMonitor()

    @Published private(set) var alerts: [WeatherAlert] = []
    @Published private(set) var lastChecked: Date?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isChecking = false

    private let client = NWSClient()
    private let tracker = AlertTracker()

    /// Returns true if the check completed (even if there was nothing to report).
    @discardableResult
    func check() async -> Bool {
        guard let coordinate = LocationManager.shared.savedCoordinate else {
            errorMessage = "Waiting for your location."
            return false
        }
        guard !isChecking else { return true }
        isChecking = true
        defer { isChecking = false }

        do {
            let fetched = try await client.activeAlerts(latitude: coordinate.latitude,
                                                        longitude: coordinate.longitude)
            let current = fetched
                .filter { !$0.hasExpired() }
                .sorted { $0.severity > $1.severity }
            alerts = current
            lastChecked = Date()
            errorMessage = nil

            let threshold = Settings.minimumSeverity
            let fresh = tracker.unseen(current.filter { $0.severity >= threshold })
            for alert in fresh {
                await NotificationManager.shared.post(alert)
            }
            tracker.markSeen(fresh)
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
