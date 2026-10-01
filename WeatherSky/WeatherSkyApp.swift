//
//  WeatherSkyApp.swift
//  WeatherSky
//

import SwiftUI

@main
struct WeatherSkyApp: App {
    @Environment(\.scenePhase) private var scenePhase

    @MainActor
    init() {
        // Touch the singletons at launch so iOS can relaunch us for location events and the
        // notification delegate is in place before any notification arrives.
        _ = NotificationManager.shared
        LocationManager.shared.onUpdate = {
            Task { await AlertMonitor.shared.check() }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { phase in
            if phase == .background {
                BackgroundRefresh.schedule()
            }
        }
        .backgroundTask(.appRefresh(BackgroundRefresh.identifier)) {
            BackgroundRefresh.schedule()
            await AlertMonitor.shared.check()
        }
    }
}
