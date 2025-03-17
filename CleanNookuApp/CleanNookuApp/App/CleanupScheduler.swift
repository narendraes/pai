import Foundation
import BackgroundTasks

class CleanupScheduler {
    static let shared = CleanupScheduler()
    
    private let taskIdentifier = "com.nooku.app.mediacleanup"
    private let cameraManager = CameraManager()
    
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
            self.cameraManager.cleanupOldMedia()
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
                self.cameraManager.cleanupOldMedia()
                
                // Update the last cleanup date
                DispatchQueue.main.async {
                    UserDefaults.standard.set(now, forKey: "lastMediaCleanupDate")
                }
            }
        }
    }
} 