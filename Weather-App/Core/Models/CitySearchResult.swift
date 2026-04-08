import Foundation

struct CitySearchResult: Codable, Identifiable {
    var id: String { "\(name)-\(country)-\(lat)-\(lon)" }
    let name: String
    let country: String
    let state: String?
    let lat: Double
    let lon: Double

    /// Display label e.g. "Khulna, BD" or "Khulna, Khulna Division, BD"
    var displayName: String {
        if let state = state, !state.isEmpty {
            return "\(name), \(state), \(country)"
        }
        return "\(name), \(country)"
    }
}
