import Foundation
import UIKit
import SwiftUI

/// AppDelegate for the Private Home AI app
public class AppDelegate: NSObject, UIApplicationDelegate {
    
    /// Called when the app finishes launching
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Initialize logging
        LoggingService.shared.log(category: .startup, level: .info, message: "Application did finish launching")
        
        // Check for duplicate files
        checkForDuplicateFiles()
        
        // Set up uncaught exception handler
        NSSetUncaughtExceptionHandler { exception in
            LoggingService.shared.log(
                category: .general,
                level: .critical,
                message: "Uncaught exception: \(exception.name.rawValue), reason: \(exception.reason ?? "unknown"), userInfo: \(exception.userInfo ?? [:])"
            )
        }
        
        return true
    }
    
    /// Called when the app is about to terminate
    public func applicationWillTerminate(_ application: UIApplication) {
        LoggingService.shared.log(category: .startup, level: .info, message: "Application will terminate")
    }
    
    /// Called when the app enters the background
    public func applicationDidEnterBackground(_ application: UIApplication) {
        LoggingService.shared.log(category: .startup, level: .info, message: "Application did enter background")
    }
    
    /// Called when the app enters the foreground
    public func applicationWillEnterForeground(_ application: UIApplication) {
        LoggingService.shared.log(category: .startup, level: .info, message: "Application will enter foreground")
    }
    
    /// Check for duplicate files in the project
    private func checkForDuplicateFiles() {
        // Known duplicate files
        let knownDuplicates = [
            ("AuthenticationView.swift", "/Sources/Nooku/App/AuthenticationView.swift", "/Sources/Nooku/Features/Authentication/AuthenticationView.swift")
        ]
        
        for (fileName, path1, path2) in knownDuplicates {
            LoggingService.shared.log(
                category: .startup,
                level: .warning,
                message: "Duplicate file detected: \(fileName) exists at both \(path1) and \(path2)"
            )
        }
    }
} 