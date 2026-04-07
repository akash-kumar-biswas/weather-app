import Foundation

final class WeatherAPIClient {
    
    static let shared = WeatherAPIClient()
    
    private init() {}
    
    func fetchWeather(for city: String, units: String = "metric") async throws -> WeatherResponse {
        
        let apiKey = APIKeys.openWeatherKey
        
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        
        let urlString = """
        https://api.openweathermap.org/data/2.5/weather?q=\(encodedCity)&appid=\(apiKey)&units=\(units)
        """
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        let weather = try decoder.decode(WeatherResponse.self, from: data)
        
        return weather
    }
    
    func fetchForecast(for city: String, units: String = "metric") async throws -> ForecastResponse {
        
        let apiKey = APIKeys.openWeatherKey
        let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? city
        
        let urlString = """
        https://api.openweathermap.org/data/2.5/forecast?q=\(encodedCity)&appid=\(apiKey)&units=\(units)
        """
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(ForecastResponse.self, from: data)
    }
    
    //for fetching weather of current location
    func fetchWeather(latitude: Double, longitude: Double, units: String = "metric") async throws -> WeatherResponse {
        
        let apiKey = APIKeys.openWeatherKey
        
        let urlString = """
        https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)
        """
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(WeatherResponse.self, from: data)
    }
    //FETCH forecast for latitude and longitude
    func fetchForecast(latitude: Double, longitude: Double, units: String = "metric") async throws -> ForecastResponse {
        
        let apiKey = APIKeys.openWeatherKey
        
        let urlString = """
        https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=\(units)
        """
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        return try decoder.decode(ForecastResponse.self, from: data)
    }

    // MARK: - Geocoding / City Suggestions
    /// Returns up to `limit` city suggestions for the given query using the OWM Geocoding API.
    func fetchCitySuggestions(for query: String, limit: Int = 7) async throws -> [CitySearchResult] {
        let apiKey = APIKeys.openWeatherKey
        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query

        let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(encoded)&limit=\(limit)&appid=\(apiKey)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode([CitySearchResult].self, from: data)
    }
}
