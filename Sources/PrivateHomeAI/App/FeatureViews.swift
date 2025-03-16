import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Chat")
                .font(.largeTitle)
                .padding()
            
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
    }
}

struct CameraView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Cameras")
                .font(.largeTitle)
                .padding()
            
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
    }
}

struct AnalysisView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack {
            Text("Analysis")
                .font(.largeTitle)
                .padding()
            
            Text("Coming soon...")
                .foregroundColor(.secondary)
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        Form {
            Section(header: Text("App Settings")) {
                Toggle("Dark Mode", isOn: .constant(true))
                Toggle("Notifications", isOn: .constant(true))
            }
            
            Section(header: Text("Connection")) {
                HStack {
                    Text("Status")
                    Spacer()
                    Text(appState.connectionStatus.description)
                        .foregroundColor(appState.isConnected ? .green : .red)
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