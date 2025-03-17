import SwiftUI

@main
struct NookuApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Register background tasks
        CleanupScheduler.shared.registerBackgroundTask()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Check for jailbreak
                    if JailbreakDetectionService.shared.isJailbroken() {
                        appState.showJailbreakAlert = true
                    }
                    
                    // Schedule media cleanup
                    CleanupScheduler.shared.scheduleCleanup()
                    
                    // Check if cleanup is needed when app becomes active
                    NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                        CleanupScheduler.shared.cleanupOnAppActive()
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
