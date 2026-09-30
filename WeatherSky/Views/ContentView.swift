//
//  ContentView.swift
//  WeatherSky
//

import CoreLocation
import SwiftUI
import UserNotifications

@MainActor
struct ContentView: View {
    @StateObject private var monitor = AlertMonitor.shared
    @StateObject private var location = LocationManager.shared
    @StateObject private var notifications = NotificationManager.shared
    @AppStorage(Settings.minimumSeverityKey) private var minimumSeverity = AlertSeverity.severe.rawValue

    var body: some View {
        NavigationStack {
            List {
                setupSection
                alertsSection
                settingsSection
            }
            .navigationTitle("WeatherSky")
            .toolbar {
                Button {
                    Task { await monitor.check() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(monitor.isChecking)
                .accessibilityLabel("Check now")
            }
            .refreshable { await monitor.check() }
        }
        .task {
            await notifications.refreshAuthorization()
            await monitor.check()
        }
    }

    // MARK: Sections

    @ViewBuilder
    private var setupSection: some View {
        let needsNotifications = notifications.authorization == .notDetermined
        let needsLocation = location.authorization == .notDetermined
            || location.authorization == .authorizedWhenInUse
        let blocked = notifications.authorization == .denied
            || location.authorization == .denied || location.authorization == .restricted

        if needsNotifications || needsLocation || blocked {
            Section("Set up alerts") {
                if needsNotifications {
                    Button("Allow notifications") {
                        Task { await notifications.requestAuthorization() }
                    }
                }
                if needsLocation {
                    Button(location.authorization == .notDetermined
                           ? "Allow location" : "Allow location “Always” for background alerts") {
                        location.requestAuthorization()
                    }
                }
                if blocked {
                    Text("Notifications or location are turned off. Enable them in Settings to receive alerts.")
                        .font(.footnote)
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var alertsSection: some View {
        Section {
            if let message = monitor.errorMessage {
                Text(message).foregroundStyle(.secondary)
            } else if monitor.alerts.isEmpty {
                Label("No active alerts for your location", systemImage: "checkmark.circle")
                    .foregroundStyle(.secondary)
            }
            ForEach(monitor.alerts) { alert in
                NavigationLink(destination: AlertDetailView(alert: alert)) {
                    AlertRow(alert: alert)
                }
            }
        } header: {
            Text("Active alerts")
        } footer: {
            if let checked = monitor.lastChecked {
                Text("Last checked \(checked.formatted(date: .omitted, time: .shortened))")
            }
        }
    }

    private var settingsSection: some View {
        Section {
            Picker("Notify me for", selection: $minimumSeverity) {
                ForEach([AlertSeverity.moderate, .severe, .extreme]) { severity in
                    Text("\(severity.rawValue) and above").tag(severity.rawValue)
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Alerts come from the US National Weather Service and cover the United States only.")
        }
    }
}

struct AlertRow: View {
    let alert: WeatherAlert

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(alert.event).font(.headline)
                if alert.isApproaching() {
                    Text("Approaching")
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.25), in: Capsule())
                }
            }
            Text(alert.severity.rawValue)
                .font(.subheadline)
                .foregroundStyle(color(for: alert.severity))
            if let headline = alert.headline {
                Text(headline).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private func color(for severity: AlertSeverity) -> Color {
        switch severity {
        case .extreme: return .red
        case .severe: return .orange
        case .moderate: return .yellow
        default: return .secondary
        }
    }
}

struct AlertDetailView: View {
    let alert: WeatherAlert

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(alert.areaDescription).font(.subheadline).foregroundStyle(.secondary)
                if let onset = alert.onset {
                    Text("Begins \(onset.formatted(date: .abbreviated, time: .shortened))")
                }
                if let expires = alert.expires {
                    Text("Ends \(expires.formatted(date: .abbreviated, time: .shortened))")
                }
                Text(alert.detail)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(alert.event)
        .navigationBarTitleDisplayMode(.inline)
    }
}
