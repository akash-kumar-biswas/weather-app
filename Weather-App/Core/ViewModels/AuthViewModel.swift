import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init() {
        self.user = Auth.auth().currentUser
        
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
    
    // MARK: - Auth Actions
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth()
                .createUser(withEmail: email, password: password)
            self.user = result.user
        } catch {
            errorMessage = friendlyMessage(from: error)
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)
            self.user = result.user
        } catch {
            errorMessage = friendlyMessage(from: error)
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            user = nil
        } catch {
            errorMessage = friendlyMessage(from: error)
        }
    }
    
    // MARK: - Error Mapping
    
    private func friendlyMessage(from error: Error) -> String {
        let code = AuthErrorCode(_nsError: error as NSError)
        switch code.code {
        case .wrongPassword:
            return "Wrong password. Please try again."
        case .invalidCredential:
            return "Incorrect email or password. Please try again."
        case .userNotFound:
            return "No account found with this email. Please sign up first."
        case .invalidEmail:
            return "Please enter a valid email address."
        case .emailAlreadyInUse:
            return "This email is already registered. Try logging in instead."
        case .weakPassword:
            return "Password is too weak. Please use at least 6 characters."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .tooManyRequests:
            return "Too many failed attempts. Please wait a moment and try again."
        case .userDisabled:
            return "This account has been disabled. Please contact support."
        case .requiresRecentLogin:
            return "Please log out and sign in again to continue."
        default:
            return "Something went wrong. Please try again."
        }
    }
}
