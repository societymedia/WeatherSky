//
//  WeatherAlert.swift
//  WeatherSky
//

import Foundation

/// NWS CAP severity levels, ordered from least to most severe.
enum AlertSeverity: String, CaseIterable, Comparable, Identifiable {
    case unknown = "Unknown"
    case minor = "Minor"
    case moderate = "Moderate"
    case severe = "Severe"
    case extreme = "Extreme"

    var id: String { rawValue }

    private var rank: Int {
        switch self {
        case .unknown: return 0
        case .minor: return 1
        case .moderate: return 2
        case .severe: return 3
        case .extreme: return 4
        }
    }

    static func < (lhs: AlertSeverity, rhs: AlertSeverity) -> Bool {
        return lhs.rank < rhs.rank
    }
}

struct WeatherAlert: Identifiable, Equatable {
    let id: String
    let event: String
    let headline: String?
    let detail: String
    let severity: AlertSeverity
    let onset: Date?
    let expires: Date?
    let areaDescription: String

    /// An alert whose onset is still in the future is "approaching" (e.g. a Watch).
    func isApproaching(at now: Date = Date()) -> Bool {
        guard let onset = onset else { return false }
        return onset > now
    }

    func hasExpired(at now: Date = Date()) -> Bool {
        guard let expires = expires else { return false }
        return expires <= now
    }
}

// MARK: - NWS GeoJSON decoding

extension WeatherAlert {
    private struct Collection: Decodable {
        let features: [Feature]
    }

    private struct Feature: Decodable {
        let properties: Properties
    }

    private struct Properties: Decodable {
        let id: String
        let event: String
        let headline: String?
        let description: String?
        let severity: String?
        let status: String?
        let onset: Date?
        let effective: Date?
        let expires: Date?
        let ends: Date?
        let areaDesc: String?
    }

    /// Parses an `api.weather.gov/alerts/active` response, dropping anything that isn't a real,
    /// current alert (tests, exercises, drafts).
    static func decode(from data: Data) throws -> [WeatherAlert] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            if let date = WeatherAlert.parseDate(string) {
                return date
            }
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath,
                                      debugDescription: "Unrecognized date: \(string)"))
        }
        let collection = try decoder.decode(Collection.self, from: data)
        return collection.features
            .map { $0.properties }
            .filter { $0.status == nil || $0.status == "Actual" }
            .map { props in
                WeatherAlert(
                    id: props.id,
                    event: props.event,
                    headline: props.headline,
                    detail: props.description ?? "",
                    severity: props.severity.flatMap(AlertSeverity.init(rawValue:)) ?? .unknown,
                    // Fall back to `effective` so alerts without an explicit onset still have a start time.
                    onset: props.onset ?? props.effective,
                    expires: props.ends ?? props.expires,
                    areaDescription: props.areaDesc ?? "")
            }
    }

    private static func parseDate(_ string: String) -> Date? {
        let plain = ISO8601DateFormatter()
        if let date = plain.date(from: string) { return date }
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: string)
    }
}
