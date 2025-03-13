import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Private Home AI")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Secure local AI assistant")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer().frame(height: 40)
            
            // Login form will go here
            Text("Authentication form placeholder")
            
            Button("Login (Demo)") {
                viewModel.authenticate()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .padding()
        .onReceive(viewModel.$isAuthenticated) { isAuthenticated in
            appState.isAuthenticated = isAuthenticated
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
            .environmentObject(AppState())
    }
} 