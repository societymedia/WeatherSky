//
//  NWSClient.swift
//  WeatherSky
//

import Foundation

enum NWSError: LocalizedError {
    case badResponse(Int)
    case outsideCoverage

    var errorDescription: String? {
        switch self {
        case .badResponse(let code):
            return "The weather service returned an error (\(code))."
        case .outsideCoverage:
            return "Alerts are only available for locations in the United States."
        }
    }
}

/// Thin client for the National Weather Service alerts API (https://www.weather.gov/documentation/services-web-api).
/// Free, no API key, US-only.
struct NWSClient {
    var session: URLSession = .shared

    func activeAlerts(latitude: Double, longitude: Double) async throws -> [WeatherAlert] {
        var components = URLComponents(string: "https://api.weather.gov/alerts/active")!
        // NWS rejects more than 4 decimal places of precision.
        components.queryItems = [
            URLQueryItem(name: "point", value: String(format: "%.4f,%.4f", latitude, longitude))
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/geo+json", forHTTPHeaderField: "Accept")
        // NWS asks every client to identify itself.
        request.setValue("WeatherSky iOS app (com.societymedia.WeatherSky)", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20

        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            // NWS answers 400/404 for points it has no coverage of.
            if http.statusCode == 400 || http.statusCode == 404 {
                throw NWSError.outsideCoverage
            }
            throw NWSError.badResponse(http.statusCode)
        }
        return try WeatherAlert.decode(from: data)
    }
}
