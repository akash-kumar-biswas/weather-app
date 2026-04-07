import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
}

struct ForecastItem: Codable {
    let dt: TimeInterval
    let main: ForecastMain
    let weather: [Weather]
}

struct ForecastMain: Codable {
    let temp: Double
}
