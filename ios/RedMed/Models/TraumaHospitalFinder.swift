import CoreLocation
import Foundation

/// Verified Level I/II trauma hospital from the bundled offline directory (ACS / state designations).
/// Shown for transport decisions when delay may not be survivable — not routine ER lookup.
struct TraumaHospital: Identifiable, Codable, Equatable {
    let name: String
    let latitude: Double
    let longitude: Double
    let level: Int
    let city: String
    let state: String
    let county: String
    let phone: String

    var id: String { "\(name)|\(latitude)|\(longitude)" }

    enum CodingKeys: String, CodingKey {
        case name = "n"
        case latitude = "lat"
        case longitude = "lng"
        case level = "l"
        case city = "c"
        case state = "s"
        case county = "co"
        case phone = "p"
    }

    var levelLabel: String { "Level \(level) trauma" }

    var mapsURL: URL? {
        URL(string: "https://maps.apple.com/?daddr=\(latitude),\(longitude)")
    }
}

/// Offline trauma lookup: state → city → hospital. JSON loads on first use.
enum TraumaHospitalFinder {
    /// All U.S. states and D.C. — picker lists every jurisdiction; hospital lookup
    /// still comes from the bundled catalog (empty list when none verified).
    static let allStates: [String] = [
        "AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL",
        "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA",
        "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE",
        "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI",
        "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY",
    ]

    private static var cachedIndex: [String: [String: [TraumaHospital]]]?

    private static var regionIndex: [String: [String: [TraumaHospital]]] {
        if let cachedIndex { return cachedIndex }
        let loaded = Self.loadRegionIndex()
        cachedIndex = loaded
        return loaded
    }

    private static func loadRegionIndex() -> [String: [String: [TraumaHospital]]] {
        guard let url = Bundle.main.url(forResource: "trauma-hospitals", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode([TraumaHospital].self, from: data) else {
            return [:]
        }
        var index: [String: [String: [TraumaHospital]]] = [:]
        for hospital in catalog {
            index[hospital.state, default: [:]][hospital.city, default: []].append(hospital)
        }
        for state in index.keys {
            for city in index[state]!.keys {
                index[state]![city]!.sort { $0.name < $1.name }
            }
        }
        return index
    }

    static var states: [String] {
        allStates
    }

    static func cities(in state: String, from coordinate: CLLocationCoordinate2D? = nil) -> [String] {
        guard let cities = regionIndex[state] else { return [] }
        var names = Array(cities.keys)
        if let coordinate {
            names.sort {
                nearestDistance(from: coordinate, hospitals: cities[$0] ?? [])
                    < nearestDistance(from: coordinate, hospitals: cities[$1] ?? [])
            }
        } else {
            names.sort()
        }
        return names
    }

    static func hospitals(
        state: String,
        city: String,
        from coordinate: CLLocationCoordinate2D? = nil
    ) -> [TraumaHospital] {
        guard !state.isEmpty, !city.isEmpty else { return [] }
        var list = regionIndex[state]?[city] ?? []
        if let coordinate {
            list.sort {
                distanceMiles(from: coordinate, to: $0) < distanceMiles(from: coordinate, to: $1)
            }
        }
        return list
    }

    static func distanceMiles(from coordinate: CLLocationCoordinate2D, to hospital: TraumaHospital) -> Double {
        let here = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let there = CLLocation(latitude: hospital.latitude, longitude: hospital.longitude)
        return here.distance(from: there) / 1609.344
    }

    static func distanceLabel(from coordinate: CLLocationCoordinate2D, to hospital: TraumaHospital) -> String {
        let miles = distanceMiles(from: coordinate, to: hospital)
        if miles < 0.2 { return "Nearby" }
        if miles < 10 { return String(format: "%.1f mi", miles) }
        return String(format: "%.0f mi", miles)
    }

    static func matchCity(state: String, name: String) -> String? {
        let target = name.lowercased().trimmingCharacters(in: .whitespaces)
        guard !target.isEmpty else { return nil }
        let options = cities(in: state)
        if let exact = options.first(where: { $0.lowercased() == target }) { return exact }
        return options.first(where: {
            let city = $0.lowercased()
            return city.contains(target) || target.contains(city)
        })
    }

    private static func nearestDistance(from coordinate: CLLocationCoordinate2D, hospitals: [TraumaHospital]) -> Double {
        hospitals.map { distanceMiles(from: coordinate, to: $0) }.min() ?? .infinity
    }
}
