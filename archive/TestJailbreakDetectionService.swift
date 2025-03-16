import Foundation

// Mock FileManager for testing
class MockFileManager: FileManager {
    var existingFiles: [String] = []
    
    override func fileExists(atPath path: String) -> Bool {
        return existingFiles.contains(path)
    }
}

// Protocol definition
protocol JailbreakDetectionServiceProtocol {
    func isJailbroken() -> Bool
}

// JailbreakDetectionService implementation (simplified for testing)
class JailbreakDetectionService: JailbreakDetectionServiceProtocol {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    func isJailbroken() -> Bool {
        // For testing purposes, we'll only check for jailbreak files
        return checkForJailbreakFiles()
    }
    
    private func checkForJailbreakFiles() -> Bool {
        let jailbreakFiles = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt"
        ]
        
        for path in jailbreakFiles {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
}

// Test function
func testJailbreakDetection() {
    print("Testing JailbreakDetectionService...")
    
    // Test case 1: No jailbreak files
    let mockFileManager1 = MockFileManager()
    let service1 = JailbreakDetectionService(fileManager: mockFileManager1)
    
    let result1 = service1.isJailbroken()
    if result1 == false {
        print("✅ Test 1 (No jailbreak files): Passed")
    } else {
        print("❌ Test 1 (No jailbreak files): Failed")
        print("   Expected: false")
        print("   Actual: \(result1)")
    }
    
    // Test case 2: With jailbreak files
    let mockFileManager2 = MockFileManager()
    mockFileManager2.existingFiles = ["/Applications/Cydia.app"]
    let service2 = JailbreakDetectionService(fileManager: mockFileManager2)
    
    let result2 = service2.isJailbroken()
    if result2 == true {
        print("✅ Test 2 (With jailbreak files): Passed")
    } else {
        print("❌ Test 2 (With jailbreak files): Failed")
        print("   Expected: true")
        print("   Actual: \(result2)")
    }
    
    // Summary
    let totalTests = 2
    let passedTests = (result1 == false ? 1 : 0) + (result2 == true ? 1 : 0)
    
    print("\nTest Results: \(passedTests)/\(totalTests) tests passed")
    if passedTests == totalTests {
        print("All tests passed! 🎉")
    } else {
        print("Some tests failed. 😢")
    }
}

// Run the tests
testJailbreakDetection() 