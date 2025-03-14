import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var appState: AppState
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showBiometricLogin = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Logo and title
            VStack(spacing: 10) {
                Image(systemName: "lock.shield.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                
                Text("Private Home AI")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Secure. Private. Local.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
            
            // Login form
            VStack(spacing: 15) {
                TextField("Username", text: $username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.top, 5)
                }
                
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
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(username.isEmpty || password.isEmpty || isLoading)
                .opacity((username.isEmpty || password.isEmpty || isLoading) ? 0.6 : 1)
            }
            
            // Biometric login option
            if showBiometricLogin {
                Button(action: authenticateWithBiometrics) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Login with Face ID")
                    }
                }
                .padding(.top)
            }
            
            Spacer()
            
            // Security info
            VStack(spacing: 5) {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("End-to-end encrypted")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("Local processing only")
                        .font(.caption)
                }
                
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.green)
                    Text("No cloud storage")
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            // Check if biometric authentication is available
            showBiometricLogin = true
        }
    }
    
    private func authenticate() {
        isLoading = true
        errorMessage = nil
        
        // Simulate authentication process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if username == "demo" && password == "password" {
                withAnimation {
                    appState.isAuthenticated = true
                }
            } else {
                errorMessage = "Invalid username or password"
            }
            isLoading = false
        }
    }
    
    private func authenticateWithBiometrics() {
        isLoading = true
        errorMessage = nil
        
        // Simulate biometric authentication
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation {
                appState.isAuthenticated = true
            }
            isLoading = false
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AppState())
    }
} 