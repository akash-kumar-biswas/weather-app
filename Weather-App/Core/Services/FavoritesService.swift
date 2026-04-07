import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FavoritesService {
    
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    // MARK: - Add Favorite
    func addFavorite(city: String) async throws {
        guard let userId = userId else { return }
        
        let data: [String: Any] = [
            "city": city,
            "createdAt": Timestamp(date: Date())
        ]
        
        try await db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(city)
            .setData(data)
    }
    
    // MARK: - Remove Favorite
    func removeFavorite(city: String) async throws {
        guard let userId = userId else { return }
        
        try await db.collection("users")
            .document(userId)
            .collection("favorites")
            .document(city)
            .delete()
    }
    
    // MARK: - Listen to Favorites
    func listenFavorites(completion: @escaping ([String]) -> Void) {
        guard let userId = userId else { return }
        
        db.collection("users")
            .document(userId)
            .collection("favorites")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                
                guard let documents = snapshot?.documents else {
                    completion([])
                    return
                }
                
                let cities = documents.compactMap { $0["city"] as? String }
                completion(cities)
            }
    }
}
