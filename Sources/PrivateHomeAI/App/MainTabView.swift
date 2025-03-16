import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    init() {
        print("DEBUG: MainTabView initializing...")
    }
    
    var body: some View {
        print("DEBUG: MainTabView rendering TabView...")
        // Simplified version with basic content for debugging
        return TabView {
            // Home tab with simple content
            VStack {
                Text("Home Screen")
                    .font(.largeTitle)
                
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.blue)
                
                Text("Connection Status: \(appState.connectionStatus.description)")
                    .padding()
                
                Text("Auth Status: \(appState.isAuthenticated ? "Logged In" : "Not Logged In")")
                    .padding()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .onAppear {
                print("DEBUG: Home tab appeared")
            }
            
            // Settings tab with simple content
            VStack {
                Text("Settings Screen")
                    .font(.largeTitle)
                
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                
                Button("Log Out") {
                    print("DEBUG: Logout button tapped")
                    authViewModel.logout()
                }
                .padding()
                .background(Color.red.opacity(0.2))
                .cornerRadius(8)
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .onAppear {
                print("DEBUG: Settings tab appeared")
            }
        }
        .accentColor(.blue)
    }
}

struct ConnectionStatusOverlay: View {
    let status: ConnectionStatus
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                switch status {
                case .disconnected:
                    Image(systemName: "wifi.slash")
                    Text("Disconnected")
                case .connecting:
                    ProgressView()
                    Text("Connecting...")
                case .connected:
                    // Should not be visible when connected
                    EmptyView()
                case .error(let message):
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Error: \(message)")
                }
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 80) // Ensure it's above the tab bar
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
            .environmentObject(AuthenticationViewModel())
    }
} 