import SwiftUI

// Import app types
@_exported import struct PrivateHomeAI.AppState
@_exported import enum PrivateHomeAI.ConnectionStatus

public struct ChatView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Chat")
                    .font(.largeTitle)
                    .padding()
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Chat")
        }
    }
}

public struct CameraView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Camera")
                    .font(.largeTitle)
                    .padding()
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Camera")
        }
    }
}

public struct AnalysisView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                Text("Analysis")
                    .font(.largeTitle)
                    .padding()
                
                Text("Coming soon...")
                    .foregroundColor(.secondary)
            }
            .navigationTitle("Analysis")
        }
    }
}

public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("App Settings")) {
                    Toggle("Dark Mode", isOn: $appState.settings.useDarkMode)
                    Toggle("Notifications", isOn: $appState.settings.enableNotifications)
                }
                
                Section(header: Text("Connection")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        Label(
                            appState.connectionStatus.description,
                            systemImage: appState.connectionStatus.iconName
                        )
                        .foregroundColor(appState.connectionStatus.color)
                    }
                }
                
                Section(header: Text("About")) {
                    Text("Private Home AI")
                    Text("Version 1.0.0")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#if DEBUG
struct FeatureViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ChatView()
            CameraView()
            AnalysisView()
            SettingsView()
        }
        .environmentObject(AppState())
    }
}
#endif 