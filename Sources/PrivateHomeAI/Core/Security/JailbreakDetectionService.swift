import Foundation
import UIKit

protocol JailbreakDetectionServiceProtocol {
    func isJailbroken() -> Bool
}

class JailbreakDetectionService: JailbreakDetectionServiceProtocol {
    func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return checkForJailbreakFiles() || checkForSuspiciousApps() || checkForSuspiciousPaths() || canWriteOutsideSandbox()
        #endif
    }
    
    private func checkForJailbreakFiles() -> Bool {
        let jailbreakFiles = [
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
        
        for path in jailbreakFiles {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
    
    private func checkForSuspiciousApps() -> Bool {
        let suspiciousApps = [
            "Cydia",
            "FakeCarrier",
            "Icy",
            "IntelliScreen",
            "MxTube",
            "RockApp",
            "SBSettings",
            "WinterBoard"
        ]
        
        for app in suspiciousApps {
            if UIApplication.shared.canOpenURL(URL(string: "\(app)://")!) {
                return true
            }
        }
        
        return false
    }
    
    private func checkForSuspiciousPaths() -> Bool {
        let suspiciousPaths = [
            "/Library/Ringtones",
            "/Library/Wallpaper",
            "/usr/arm-apple-darwin9",
            "/usr/include",
            "/usr/libexec",
            "/usr/share"
        ]
        
        for path in suspiciousPaths {
            if FileManager.default.isReadableFile(atPath: path) {
                return true
            }
        }
        
        return false
    }
    
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
} 