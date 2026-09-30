//
//  Settings.swift
//  WeatherSky
//

import Foundation

enum Settings {
    static let minimumSeverityKey = "minimumSeverity"

    /// Lowest severity that triggers a notification. Defaults to Severe.
    static var minimumSeverity: AlertSeverity {
        let raw = UserDefaults.standard.string(forKey: minimumSeverityKey)
        return raw.flatMap(AlertSeverity.init(rawValue:)) ?? .severe
    }
}
