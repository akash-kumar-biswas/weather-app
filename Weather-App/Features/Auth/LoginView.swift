import SwiftUI

struct LoginView: View {
    
    @EnvironmentObject var authVM: AuthViewModel
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoginMode = true
    
    var body: some View {
        VStack(spacing: 24) {
            
            Spacer()
            
            VStack(spacing: 8) {
                Text("Weather App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(isLoginMode ? "Welcome back" : "Create your account")
                    .foregroundColor(.gray)
            }
            
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            if let error = authVM.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                Task {
                    if isLoginMode {
                        await authVM.signIn(email: email, password: password)
                    } else {
                        await authVM.signUp(email: email, password: password)
                    }
                }
            } label: {
                if authVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Text(isLoginMode ? "Login" : "Sign Up")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            
            Button {
                isLoginMode.toggle()
            } label: {
                Text(isLoginMode ?
                     "Don't have an account? Sign Up"
                     :
                     "Already have an account? Login")
                    .font(.footnote)
            }
            
            Spacer()
        }
        .padding()
    }
}
