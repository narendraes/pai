import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Private Home AI Assistant")
                    .font(.largeTitle)
                    .padding()
                
                Text("Secure, Private, Local")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 40)
                
                // Main menu buttons
                VStack(spacing: 20) {
                    NavigationLink(destination: Text("Chat View")) {
                        MenuButton(title: "Chat with AI", icon: "message.fill")
                    }
                    
                    NavigationLink(destination: Text("Camera View")) {
                        MenuButton(title: "Camera Control", icon: "camera.fill")
                    }
                    
                    NavigationLink(destination: Text("Media Analysis")) {
                        MenuButton(title: "Media Analysis", icon: "photo.fill")
                    }
                    
                    NavigationLink(destination: Text("Settings")) {
                        MenuButton(title: "Settings", icon: "gear")
                    }
                }
                
                Spacer()
                
                // Connection status
                HStack {
                    Circle()
                        .fill(appState.isConnected ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                    Text(appState.isConnected ? "Connected" : "Disconnected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

struct MenuButton: View {
    var title: String
    var icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 40)
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
