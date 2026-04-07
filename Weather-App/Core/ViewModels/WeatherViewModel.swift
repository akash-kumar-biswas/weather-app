import Foundation

@MainActor
final class WeatherViewModel: ObservableObject {
    
    @Published var weather: WeatherResponse?
    @Published var forecast: ForecastResponse?
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - City Suggestions
    @Published var citySuggestions: [CitySearchResult] = []

    /// Debounce task so we don't fire a request on every keystroke
    private var suggestionTask: Task<Void, Never>?
    
    // MARK: - Hourly (first 8 items ≈ 24 hours)
    var hourlyForecast: [ForecastItem] {
        Array(forecast?.list.prefix(8) ?? [])
    }
    
    // MARK: - Reliable Daily Forecast (5 days)
    var dailyForecast: [ForecastItem] {
        guard let forecast = forecast else { return [] }
        
        var seenDays: Set<String> = []
        var result: [ForecastItem] = []
        
        for item in forecast.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dayString = formatter.string(from: date)
            
            if !seenDays.contains(dayString) {
                seenDays.insert(dayString)
                result.append(item)
            }
        }
        
        return Array(result.prefix(5))
    }
    
    // MARK: - Fetch Weather
    func fetchWeather(for city: String, units: String = "metric") async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let current = WeatherAPIClient.shared.fetchWeather(for: city, units: units)
            async let forecastData = WeatherAPIClient.shared.fetchForecast(for: city, units: units)
            
            self.weather = try await current
            self.forecast = try await forecastData
            
        } catch {
            errorMessage = "Failed to fetch weather data."
        }
        
        isLoading = false
    }
    
    // for fetching weather of current location
    func fetchWeather(latitude: Double, longitude: Double, units: String = "metric") async {
        isLoading = true
        errorMessage = nil
        
        do {
            async let current = WeatherAPIClient.shared
                .fetchWeather(latitude: latitude, longitude: longitude, units: units)
            
            async let forecastData = WeatherAPIClient.shared
                .fetchForecast(latitude: latitude, longitude: longitude, units: units)
            
            self.weather = try await current
            self.forecast = try await forecastData
            
        } catch {
            errorMessage = "Failed to fetch location weather."
        }
        
        isLoading = false
    }

    // MARK: - City Autocomplete Suggestions
    /// Call this on every keystroke. Debounces 300 ms then hits the Geocoding API.
    func fetchSuggestions(for query: String) {
        suggestionTask?.cancel()

        guard query.count >= 2 else {
            citySuggestions = []
            return
        }

        suggestionTask = Task {
            // 300 ms debounce
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            do {
                let results = try await WeatherAPIClient.shared.fetchCitySuggestions(for: query)
                if !Task.isCancelled {
                    citySuggestions = results
                }
            } catch {
                // Silently ignore suggestion errors
                citySuggestions = []
            }
        }
    }

    func clearSuggestions() {
        suggestionTask?.cancel()
        citySuggestions = []
    }
}
