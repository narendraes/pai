import SwiftUI

/// The main content view for the Private Home AI app
public struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    public init() {
        print("DEBUG: ContentView initializing...")
    }
    
    public var body: some View {
        print("DEBUG: ContentView rendering basic content...")
        
        // Ultra simplified version with no dependencies
        return VStack {
            Text("Private Home AI")
                .font(.largeTitle)
                .padding()
            
            Image(systemName: "house.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding()
            
            Text("A secure home automation solution")
                .font(.headline)
                .padding()
            
            Text("Connection Status: \(appState.connectionStatus.description)")
                .padding()
            
            Button("Connect") {
                print("DEBUG: Connect button tapped")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            print("DEBUG: Basic ContentView appeared")
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