import SwiftUI

struct WeatherHomeView: View {
    
    @EnvironmentObject var appState: AppState
    
    @StateObject private var favoritesVM = FavoritesViewModel()
    @StateObject private var weatherVM = WeatherViewModel()
    @StateObject private var locationManager = LocationManager()
    
    @State private var city = ""
    @State private var hasLoadedInitialWeather = false
    @State private var isSearchFocused = false

    // Converts the stored "C"/"F" preference to the API units string
    private var apiUnits: String {
        appState.temperatureUnit == "F" ? "imperial" : "metric"
    }
    
    // Symbol shown next to the temperature
    private var unitSymbol: String {
        appState.temperatureUnit == "F" ? "°F" : "°C"
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.6)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: - Search
                    VStack(spacing: 0) {
                        HStack {
                            TextField("Search city...", text: $city, onEditingChanged: { editing in
                                isSearchFocused = editing
                                if !editing { weatherVM.clearSuggestions() }
                            })
                            .padding()
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(weatherVM.citySuggestions.isEmpty ? 15 : 15)
                            .foregroundColor(.white)
                            .textInputAutocapitalization(.never)
                            .onChange(of: city) { newValue in
                                weatherVM.fetchSuggestions(for: newValue)
                            }
                            
                            Button {
                                weatherVM.clearSuggestions()
                                Task {
                                    await weatherVM.fetchWeather(for: city, units: apiUnits)
                                }
                            } label: {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                            }
                        }

                        // MARK: - Suggestions Dropdown
                        if !weatherVM.citySuggestions.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(weatherVM.citySuggestions) { suggestion in
                                    Button {
                                        city = suggestion.name
                                        weatherVM.clearSuggestions()
                                        Task {
                                            await weatherVM.fetchWeather(for: suggestion.name, units: apiUnits)
                                        }
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "mappin.circle.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 15))
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(suggestion.name)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                if let state = suggestion.state, !state.isEmpty {
                                                    Text("\(state), \(suggestion.country)")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                } else {
                                                    Text(suggestion.country)
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 10)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(PlainButtonStyle())

                                    if suggestion.id != weatherVM.citySuggestions.last?.id {
                                        Divider().padding(.leading, 44)
                                    }
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.top, 4)
                        }
                    }
                    
                    // MARK: - Weather Content
                    if let weather = weatherVM.weather {
                        
                        VStack(spacing: 8) {
                            
                            Text(weather.name)
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                            
                            Text("\(Int(weather.main.temp))\(unitSymbol)")
                                .font(.system(size: 90, weight: .thin))
                                .foregroundColor(.white)
                            
                            Text(weather.weather.first?.description.capitalized ?? "")
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("H: \(Int(weather.main.temp + 2))\(unitSymbol)  L: \(Int(weather.main.temp - 3))\(unitSymbol)")
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 30)
                        
                        Button {
                            Task {
                                await favoritesVM.add(city: weather.name)
                            }
                        } label: {
                            Label("Add to Favorites", systemImage: "star.fill")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.yellow.opacity(0.9))
                                .foregroundColor(.black)
                                .cornerRadius(15)
                        }
                        .padding(.top, 10)
                        
                        HourlyForecastView(hourly: weatherVM.hourlyForecast, temperatureUnit: appState.temperatureUnit)
                        DailyForecastView(daily: weatherVM.dailyForecast, temperatureUnit: appState.temperatureUnit)
                    }
                    
                    if weatherVM.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding()
                    }
                    
                    if let error = weatherVM.errorMessage {
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding()
                
                // Favorite city selection
                .onChange(of: appState.selectedCity) { selectedCity in
                    if let selectedCity = selectedCity {
                        city = selectedCity
                        Task {
                            await weatherVM.fetchWeather(for: selectedCity, units: apiUnits)
                        }
                    }
                }
                // Re-fetch when the user switches temperature unit
                .onChange(of: appState.temperatureUnit) { _ in
                    guard !city.isEmpty else { return }
                    Task {
                        await weatherVM.fetchWeather(for: city, units: apiUnits)
                    }
                }
            }
            
            // Load location ONLY once
            .onAppear {
                if !hasLoadedInitialWeather {
                    hasLoadedInitialWeather = true
                    locationManager.requestLocation()
                }
            }
            
            // Fetch weather when location updates
            .onChange(of: locationManager.location) { location in
                if let location = location {
                    Task {
                        await weatherVM.fetchWeather(
                            latitude: location.coordinate.latitude,
                            longitude: location.coordinate.longitude,
                            units: apiUnits
                        )
                    }
                } else {
                    // fallback only if location truly unavailable
                    Task {
                        await weatherVM.fetchWeather(for: "Khulna", units: apiUnits)
                    }
                }
            }
        }
    }
}
