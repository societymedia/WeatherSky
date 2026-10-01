//
//  BackgroundRefresh.swift
//  WeatherSky
//

import BackgroundTasks
import Foundation

/// Schedules periodic alert checks. iOS decides when (and whether) these actually run, so they
/// supplement, but don't replace, location-triggered checks.
enum BackgroundRefresh {
    static let identifier = "com.societymedia.WeatherSky.refresh"

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }
}
