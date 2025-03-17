import Foundation
import UIKit

/// Service for detecting jailbroken devices
public class JailbreakDetectionService {
    /// Shared instance for singleton access
    public static let shared = JailbreakDetectionService()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Check if the device is jailbroken
    /// - Returns: True if the device is jailbroken, false otherwise
    public func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        // Simulator is never jailbroken
        return false
        #else
        // Check for common jailbreak files
        let jailbreakPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]
        
        for path in jailbreakPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // Check if we can write to private directories
        let path = "/private/jailbreak.txt"
        do {
            try "jailbreak test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            // Cannot write to private directories, which is expected on non-jailbroken devices
        }
        
        return false
        #endif
    }
}
