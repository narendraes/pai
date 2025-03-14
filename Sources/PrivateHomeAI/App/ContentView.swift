import SwiftUI

/// The main content view for the Private Home AI app
public struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {}
    
    public var body: some View {
        ZStack {
            if appState.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
            }
        }
        .overlay(
            ConnectionStatusView()
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding(),
            alignment: .top
        )
        .onAppear {
            LoggingService.shared.log(category: .ui, level: .info, message: "ContentView appeared")
        }
    }
}

/// A view that displays the current connection status
struct ConnectionStatusView: View {
    @EnvironmentObject var appState: AppState
    @State private var isConnecting = false
    
    var body: some View {
        HStack {
            Image(systemName: appState.connectionStatus.iconName)
                .foregroundColor(appState.connectionStatus.color)
            
            Text(appState.connectionStatus.description)
                .foregroundColor(.white)
            
            Spacer()
            
            if appState.connectionStatus == .disconnected {
                Button(action: connect) {
                    if isConnecting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Connect")
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                }
                .disabled(isConnecting)
            }
        }
        .padding(.horizontal)
        .onAppear {
            LoggingService.shared.log(category: .ui, level: .info, message: "ConnectionStatusView appeared")
        }
    }
    
    /// Connect to the server
    private func connect() {
        LoggingService.shared.log(category: .network, level: .info, message: "Connection attempt initiated")
        
        isConnecting = true
        
        // Simulate connection process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            appState.connectionStatus = .connecting
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                // Simulate successful connection
                appState.connectionStatus = .connected
                appState.isConnected = true
                isConnecting = false
                
                LoggingService.shared.log(category: .network, level: .info, message: "Connection successful")
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
#endif 