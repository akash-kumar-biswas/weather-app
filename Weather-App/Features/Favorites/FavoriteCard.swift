import SwiftUI

struct FavoriteCard: View {
    
    let city: String
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(city)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Tap to view weather")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
                    .background(.ultraThinMaterial)
            )
        }
        .buttonStyle(.plain)
    }
}
