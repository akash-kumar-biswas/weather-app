import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject {

    @Published var favoriteCities: [String] = []
    @Published var errorMessage: String?

    private let service = FavoritesService()

    init() {
        listen()
    }

    private func listen() {
        service.listenFavorites { [weak self] cities in
            self?.favoriteCities = cities
        }
    }

    func add(city: String) async {
        do {
            try await service.addFavorite(city: city)
        } catch {
            errorMessage = error.localizedDescription
            print("Add favorite failed:", error)
        }
    }

    func remove(city: String) async {
        do {
            try await service.removeFavorite(city: city)
        } catch {
            errorMessage = error.localizedDescription
            print("Remove favorite failed:", error)
        }
    }
}
