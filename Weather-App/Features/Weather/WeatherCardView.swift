import SwiftUI

struct WeatherCardView: View {
    
    let weather: WeatherResponse
    
    var body: some View {
        VStack(spacing: 25) {
            
            // City Name
            Text(weather.name)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Main Temperature
            Text("\(Int(weather.main.temp))°C")
                .font(.system(size: 70, weight: .bold))
                .foregroundColor(.white)
            
            Text(weather.weather.first?.description.capitalized ?? "")
                .foregroundColor(.white.opacity(0.8))
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Extra Information Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 20) {
                
                InfoItem(title: "Feels Like",
                         value: "\(Int(weather.main.feels_like))°C")
                
                InfoItem(title: "Humidity",
                         value: "\(weather.main.humidity)%")
                
                InfoItem(title: "Wind",
                         value: "\(weather.wind.speed) m/s")
                
                InfoItem(title: "Pressure",
                         value: "\(weather.main.pressure) hPa")
                
                if let visibility = weather.visibility {
                    InfoItem(title: "Visibility",
                             value: "\(visibility / 1000) km")
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.2), radius: 20)
    }
}
