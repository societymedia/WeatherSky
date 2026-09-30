//
//  AlertTracker.swift
//  WeatherSky
//

import Foundation

/// Remembers which alerts we've already notified about so a background check that runs every
/// few minutes doesn't buzz the phone repeatedly for the same warning.
struct AlertTracker {
    private let defaults: UserDefaults
    private let key = "notifiedAlerts"
    /// How long to remember an alert that has no expiry time.
    private let fallbackRetention: TimeInterval = 24 * 60 * 60

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Returns the alerts that haven't been notified yet.
    func unseen(_ alerts: [WeatherAlert]) -> [WeatherAlert] {
        let seen = load()
        return alerts.filter { seen[$0.id] == nil }
    }

    /// Records alerts as notified and forgets ones that have since expired.
    func markSeen(_ alerts: [WeatherAlert], now: Date = Date()) {
        var seen = load()
        for alert in alerts {
            seen[alert.id] = alert.expires ?? now.addingTimeInterval(fallbackRetention)
        }
        seen = seen.filter { $0.value > now }
        defaults.set(seen.mapValues { $0.timeIntervalSince1970 }, forKey: key)
    }

    private func load() -> [String: Date] {
        let raw = defaults.dictionary(forKey: key) as? [String: TimeInterval] ?? [:]
        return raw.mapValues { Date(timeIntervalSince1970: $0) }
    }
}
