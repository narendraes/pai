import Foundation
import UIKit

/// Service for detecting jailbroken devices
public class JailbreakDetectionService: JailbreakDetectionServiceProtocol {
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
            try "test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
        #endif
    }
    
    /// Check if any of the specified paths exist
    /// - Parameter paths: Array of file paths to check
    /// - Returns: True if any path exists, false otherwise
    private func fileExists(paths: [String]) -> Bool {
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    /// Check if the app can open suspicious URL schemes
    /// - Returns: True if any suspicious URL scheme can be opened, false otherwise
    private func canOpenSuspiciousURLSchemes() -> Bool {
        for scheme in suspiciousURLSchemes {
            if let url = URL(string: scheme) {
                if UIApplication.shared.canOpenURL(url) {
                    return true
                }
            }
        }
        return false
    }
    
    /// Check if the app can write outside of its sandbox
    /// - Returns: True if the app can write outside of its sandbox, false otherwise
    private func canWriteOutsideSandbox() -> Bool {
        let path = "/private/jailbreak.txt"
        do {
            try "jailbreak test".write(toFile: path, atomically: true, encoding: .utf8)
            try FileManager.default.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }
    
    /// Check for suspicious environment variables
    /// - Returns: True if suspicious environment variables are found, false otherwise
    private func hasSuspiciousEnvironmentVariables() -> Bool {
        for variable in suspiciousEnvironmentVariables {
            if getenv(variable) != nil {
                return true
            }
        }
        return false
    }
    
    /// Common jailbreak file paths
    private let jailbreakPaths = [
        "/Applications/Cydia.app",
        "/Applications/blackra1n.app",
        "/Applications/FakeCarrier.app",
        "/Applications/Icy.app",
        "/Applications/IntelliScreen.app",
        "/Applications/MxTube.app",
        "/Applications/RockApp.app",
        "/Applications/SBSettings.app",
        "/Applications/WinterBoard.app",
        "/Library/MobileSubstrate/MobileSubstrate.dylib",
        "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
        "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        "/private/var/lib/apt",
        "/private/var/lib/cydia",
        "/private/var/mobile/Library/SBSettings/Themes",
        "/private/var/stash",
        "/private/var/tmp/cydia.log",
        "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
        "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        "/usr/bin/sshd",
        "/usr/libexec/sftp-server",
        "/usr/sbin/sshd",
        "/etc/apt",
        "/bin/bash",
        "/bin/sh"
    ]
    
    /// Suspicious URL schemes
    private let suspiciousURLSchemes = [
        "cydia://",
        "sileo://",
        "zbra://",
        "filza://"
    ]
    
    /// Suspicious environment variables
    private let suspiciousEnvironmentVariables = [
        "DYLD_INSERT_LIBRARIES",
        "DYLD_FORCE_FLAT_NAMESPACE",
        "DYLD_PRINT_TO_FILE"
    ]
} 