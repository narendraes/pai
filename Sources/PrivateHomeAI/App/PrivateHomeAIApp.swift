import SwiftUI
import Combine
import Security
import LocalAuthentication

// Import app services
@_exported import struct PrivateHomeAI.AppState
@_exported import class PrivateHomeAI.JailbreakDetectionService
@_exported import class PrivateHomeAI.SSHService

@main
struct PrivateHomeAIApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        print("DEBUG: PrivateHomeAIApp initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    print("DEBUG: PrivateHomeAIApp rendering ContentView...")
                    print("DEBUG: ContentView onAppear triggered")
                    // Check for jailbreak
                    if JailbreakDetectionService.shared.isJailbroken() {
                        print("DEBUG: Jailbreak detected")
                        appState.showJailbreakAlert = true
                    }
                }
                .alert("Security Warning", isPresented: $appState.showJailbreakAlert) {
                    Button("Exit", role: .destructive) {
                        exit(0)
                    }
                } message: {
                    Text("This device appears to be jailbroken. For security reasons, this app cannot run on jailbroken devices.")
                }
        }
    }
} 