import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Text("Chat View Placeholder")
                .tabItem {
                    Label("Chat", systemImage: "message.fill")
                }
                .tag(0)
            
            Text("Cameras View Placeholder")
                .tabItem {
                    Label("Cameras", systemImage: "video.fill")
                }
                .tag(1)
            
            Text("Analysis View Placeholder")
                .tabItem {
                    Label("Analysis", systemImage: "chart.bar.fill")
                }
                .tag(2)
            
            Text("Settings View Placeholder")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
} 