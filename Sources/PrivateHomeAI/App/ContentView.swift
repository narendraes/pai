import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        Group {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(AppState.TabSelection.chat)
            
            CameraView()
                .tabItem {
                    Label("Cameras", systemImage: "video.fill")
                }
                .tag(AppState.TabSelection.cameras)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "magnifyingglass")
                }
                .tag(AppState.TabSelection.analysis)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppState.TabSelection.settings)
        }
        .overlay(
            ConnectionStatusView()
                .padding(.top, 4)
            , alignment: .top
        )
    }
}

struct ConnectionStatusView: View {
    @EnvironmentObject private var appState: AppState
    
    var isConnected: Bool {
        if case .connected = appState.connectionStatus {
            return true
        }
        return false
    }
    
    var isDisconnected: Bool {
        if case .disconnected = appState.connectionStatus {
            return true
        }
        return false
    }
    
    var body: some View {
        if !isConnected {
            HStack {
                Image(systemName: appState.connectionStatus.iconName)
                    .foregroundColor(appState.connectionStatus.color)
                
                Text(appState.connectionStatus.description)
                    .font(.caption)
                    .foregroundColor(appState.connectionStatus.color)
                
                if isDisconnected {
                    Button("Connect") {
                        connectToServer()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(Color(UIColor.systemBackground).opacity(0.8))
            .cornerRadius(12)
            .shadow(radius: 2)
        }
    }
    
    private func connectToServer() {
        appState.connectionStatus = .connecting
        
        // Simulate connection process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appState.connectionStatus = .connected
            appState.isConnected = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
} 