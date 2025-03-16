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
                .tag(TabSelection.chat)
            
            CameraView()
                .tabItem {
                    Label("Cameras", systemImage: "video.fill")
                }
                .tag(TabSelection.cameras)
            
            AnalysisView()
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(TabSelection.analysis)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabSelection.settings)
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