import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
            
            DevicesView()
                .tabItem {
                    Label("Devices", systemImage: "display")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
        .overlay(
            Group {
                if !appState.isConnectedToMac {
                    ConnectionStatusOverlay(status: appState.connectionStatus)
                }
            }
        )
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