import SwiftUI
import BackgroundTasks
import UIKit

// Import CameraManager
import AVFoundation

// Define CleanupScheduler directly in this file
class CleanupScheduler {
    static let shared = CleanupScheduler()
    
    private let taskIdentifier = "com.nooku.app.mediacleanup"
    private let mediaManager = MediaCleanupManager()
    
    private init() {}
    
    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleCleanupTask(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleCleanup() {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60 * 60) // Schedule for tomorrow
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Media cleanup scheduled successfully")
        } catch {
            print("Could not schedule media cleanup: \(error)")
        }
    }
    
    private func handleCleanupTask(task: BGProcessingTask) {
        // Schedule the next cleanup
        scheduleCleanup()
        
        // Create a task that performs the cleanup
        let cleanupOperation = BlockOperation {
            self.mediaManager.cleanupOldMedia()
        }
        
        // Set up a completion handler
        cleanupOperation.completionBlock = {
            task.setTaskCompleted(success: !cleanupOperation.isCancelled)
        }
        
        // Set up an expiration handler
        task.expirationHandler = {
            cleanupOperation.cancel()
        }
        
        // Start the operation
        OperationQueue().addOperation(cleanupOperation)
    }
    
    // For apps that don't support background tasks, we can use this method
    // to clean up when the app becomes active
    func cleanupOnAppActive() {
        // Check when the last cleanup was performed
        let lastCleanupDate = UserDefaults.standard.object(forKey: "lastMediaCleanupDate") as? Date
        let now = Date()
        
        // If it's been more than a week since the last cleanup (or never cleaned up)
        if lastCleanupDate == nil || now.timeIntervalSince(lastCleanupDate!) > 7 * 24 * 60 * 60 {
            // Perform cleanup
            DispatchQueue.global(qos: .background).async {
                self.mediaManager.cleanupOldMedia()
                
                // Update the last cleanup date
                DispatchQueue.main.async {
                    UserDefaults.standard.set(now, forKey: "lastMediaCleanupDate")
                }
            }
        }
    }
}

// Define MediaCleanupManager for CleanupScheduler
class MediaCleanupManager {
    func cleanupOldMedia() {
        // Implementation for cleaning up old media
        print("Cleaning up old media...")
        
        // Get the media directory
        let fileManager = FileManager.default
        guard let mediaDirectory = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Media") else {
            return
        }
        
        // Get all files in the directory
        guard let files = try? fileManager.contentsOfDirectory(at: mediaDirectory, includingPropertiesForKeys: [.creationDateKey], options: []) else {
            return
        }
        
        // Get the date one week ago
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)
        
        // Delete files older than one week
        for file in files {
            do {
                let attributes = try fileManager.attributesOfItem(atPath: file.path)
                if let creationDate = attributes[.creationDate] as? Date, creationDate < oneWeekAgo {
                    try fileManager.removeItem(at: file)
                    print("Deleted old media file: \(file.lastPathComponent)")
                }
            } catch {
                print("Error cleaning up media file: \(error)")
            }
        }
    }
}

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
