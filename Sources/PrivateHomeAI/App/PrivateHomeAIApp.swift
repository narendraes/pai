import SwiftUI

@main
struct PrivateHomeAIApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var authViewModel = DependencyContainer.shared.authenticationViewModel
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(authViewModel)
        }
    }
} 