import SwiftUI
import Combine

@main
struct NookuApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        print("DEBUG: NookuApp initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    print("DEBUG: NookuApp rendering ContentView...")
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

/// Tab selection options
enum TabSelection {
    case chat
    case cameras
    case analysis
    case settings
}

// ConnectionStatus enum is now imported from Core/Network/ConnectionStatus.swift 