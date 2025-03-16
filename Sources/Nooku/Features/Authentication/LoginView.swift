import SwiftUI
import LocalAuthentication

/// A view that handles user login
public struct LoginView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showBiometricLogin: Bool = false
    @State private var showError: Bool = false
    
    public var body: some View {
        VStack(spacing: 20) {
            // Logo and title
            Image(systemName: "lock.shield")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            
            Text("Private Home AI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Secure Login")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Error message
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Login form
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button(action: authenticate) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(isLoading)
                
                if showBiometricLogin {
                    Button(action: authenticateWithBiometrics) {
                        HStack {
                            Image(systemName: "faceid")
                            Text("Login with Face ID")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Security information
            VStack(spacing: 8) {
                Label("End-to-end encrypted", systemImage: "lock.fill")
                Label("Local processing only", systemImage: "cpu")
                Label("No cloud storage", systemImage: "xmark.cloud")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            // Check if biometric authentication is available
            let (available, _) = BiometricAuthService.shared.biometricAuthAvailable()
            showBiometricLogin = available
            
            // Log view appearance
            LoggingService.shared.log(category: .authentication, level: .info, message: "LoginView appeared")
        }
    }
    
    /// Authenticate the user with username and password
    private func authenticate() {
        LoggingService.shared.log(category: .authentication, level: .info, message: "Login attempt with username: \(username)")
        
        isLoading = true
        errorMessage = nil
        
        // Simulate authentication process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if username == "admin" && password == "password" {
                LoggingService.shared.log(category: .authentication, level: .info, message: "Login successful for user: \(username)")
                appState.isAuthenticated = true
            } else {
                LoggingService.shared.log(category: .authentication, level: .warning, message: "Login failed for user: \(username)")
                errorMessage = "Invalid username or password"
            }
            isLoading = false
        }
    }
    
    /// Authenticate the user with biometrics
    private func authenticateWithBiometrics() {
        LoggingService.shared.log(category: .authentication, level: .info, message: "Biometric authentication attempt")
        
        BiometricAuthService.shared.authenticate(reason: "Log in to Private Home AI") { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    LoggingService.shared.log(category: .authentication, level: .info, message: "Biometric authentication successful")
                    appState.isAuthenticated = true
                case .failure(let error):
                    LoggingService.shared.log(category: .authentication, level: .error, message: "Biometric authentication failed: \(error.localizedDescription)")
                    errorMessage = "Biometric authentication failed"
                    showError = true
                }
            }
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AppState())
    }
}
#endif 