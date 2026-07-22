import CoreLocation
import Foundation

/// Reverse-geocode GPS via Google Geocoding API — used on Find 911 only when
/// `google-api-key` is present in the app bundle (mirror of web config).
enum GoogleGeocoder {
    private static var apiKey: String {
        guard let url = Bundle.main.url(forResource: "google-api-key", withExtension: nil),
              let text = try? String(contentsOf: url, encoding: .utf8) else { return "" }
        let key = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if key.isEmpty || key.hasPrefix("#") || key.contains("YOUR_GOOGLE") { return "" }
        return key.components(separatedBy: .newlines).first { line in
            let t = line.trimmingCharacters(in: .whitespaces)
            return !t.isEmpty && !t.hasPrefix("#")
        } ?? ""
    }

    struct Region: Equatable {
        var state: String
        var county: String
    }

    static func reverseGeocode(coordinate: CLLocationCoordinate2D) async -> Region? {
        let key = apiKey
        guard !key.isEmpty else { return nil }
        var components = URLComponents(string: "https://maps.googleapis.com/maps/api/geocode/json")!
        components.queryItems = [
            URLQueryItem(name: "latlng", value: "\(coordinate.latitude),\(coordinate.longitude)"),
            URLQueryItem(name: "key", value: key)
        ]
        guard let url = components.url else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  json["status"] as? String == "OK",
                  let results = json["results"] as? [[String: Any]],
                  let first = results.first,
                  let address = first["address_components"] as? [[String: Any]] else { return nil }
            return parseRegion(address)
        } catch {
            return nil
        }
    }

    private static func parseRegion(_ components: [[String: Any]]) -> Region? {
        var state = ""
        var county = ""
        for part in components {
            guard let types = part["types"] as? [String] else { continue }
            if types.contains("administrative_area_level_1") {
                state = (part["short_name"] as? String) ?? (part["long_name"] as? String) ?? ""
            }
            if types.contains("administrative_area_level_2"),
               let long = part["long_name"] as? String {
                county = long
                    .replacingOccurrences(of: " County", with: "")
                    .replacingOccurrences(of: " Parish", with: "")
            }
        }
        guard !state.isEmpty else { return nil }
        return Region(state: state, county: county)
    }
}
