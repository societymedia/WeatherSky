//
//  NotificationManager.swift
//  WeatherSky
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()

    @Published private(set) var authorization: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()

    private override init() {
        super.init()
        center.delegate = self
    }

    func refreshAuthorization() async {
        authorization = await center.notificationSettings().authorizationStatus
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        await refreshAuthorization()
        return granted
    }

    func post(_ alert: WeatherAlert) async {
        await refreshAuthorization()
        guard authorization == .authorized || authorization == .provisional else { return }

        let content = UNMutableNotificationContent()
        content.title = alert.isApproaching() ? "\(alert.event) – approaching" : alert.event
        content.subtitle = alert.areaDescription
        content.body = Self.body(for: alert)
        content.sound = .default
        content.threadIdentifier = alert.event

        // Reusing the alert ID as the request ID makes a repeat delivery replace, not duplicate.
        let request = UNNotificationRequest(identifier: alert.id, content: content, trigger: nil)
        try? await center.add(request)
    }

    private static func body(for alert: WeatherAlert) -> String {
        var parts: [String] = []
        if let headline = alert.headline {
            parts.append(headline)
        }
        if alert.isApproaching(), let onset = alert.onset {
            parts.append("Begins \(onset.formatted(date: .omitted, time: .shortened)).")
        } else if let expires = alert.expires {
            parts.append("In effect until \(expires.formatted(date: .omitted, time: .shortened)).")
        }
        return parts.joined(separator: " ")
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    /// Show alerts as banners even while the app is open.
    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter,
                                            willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        return [.banner, .list, .sound]
    }
}
