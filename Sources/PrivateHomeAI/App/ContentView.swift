import SwiftUI

/// The main content view for the app
public struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {
        print("DEBUG: ContentView initializing...")
    }
    
    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(AppState.TabSelection.chat)
            
            CameraView()
                .tabItem {
                    Label("Camera", systemImage: "video.fill")
                }
                .tag(AppState.TabSelection.camera)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(AppState.TabSelection.analysis)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(AppState.TabSelection.settings)
        }
        .onAppear {
            print("DEBUG: ContentView appeared")
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