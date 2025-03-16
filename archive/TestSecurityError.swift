import Foundation

// Define the SecurityError enum (copy from the original file)
enum SecurityError: Error, LocalizedError {
    case encryptionFailed(Error)
    case decryptionFailed(Error)
    case keychainError(OSStatus)
    case dataConversionFailed
    case invalidKey
    case jailbreakDetected
    case biometricAuthFailed
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .encryptionFailed(let error):
            return "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error.localizedDescription)"
        case .keychainError(let status):
            return "Keychain error with status: \(status)"
        case .dataConversionFailed:
            return "Failed to convert data"
        case .invalidKey:
            return "Invalid encryption key"
        case .jailbreakDetected:
            return "Device jailbreak detected"
        case .biometricAuthFailed:
            return "Biometric authentication failed"
        case .unknown(let error):
            return "Unknown security error: \(error.localizedDescription)"
        }
    }
}

// Simple test function
func testSecurityErrorDescriptions() {
    print("Testing SecurityError descriptions...")
    
    let testError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
    
    // Test each case
    let tests = [
        ("encryptionFailed", SecurityError.encryptionFailed(testError).errorDescription, "Encryption failed: Test error"),
        ("decryptionFailed", SecurityError.decryptionFailed(testError).errorDescription, "Decryption failed: Test error"),
        ("keychainError", SecurityError.keychainError(-25300).errorDescription, "Keychain error with status: -25300"),
        ("dataConversionFailed", SecurityError.dataConversionFailed.errorDescription, "Failed to convert data"),
        ("invalidKey", SecurityError.invalidKey.errorDescription, "Invalid encryption key"),
        ("jailbreakDetected", SecurityError.jailbreakDetected.errorDescription, "Device jailbreak detected"),
        ("biometricAuthFailed", SecurityError.biometricAuthFailed.errorDescription, "Biometric authentication failed"),
        ("unknown", SecurityError.unknown(testError).errorDescription, "Unknown security error: Test error")
    ]
    
    // Run tests
    var passedTests = 0
    for (name, actual, expected) in tests {
        if actual == expected {
            print("✅ \(name): Passed")
            passedTests += 1
        } else {
            print("❌ \(name): Failed")
            print("   Expected: \(expected)")
            print("   Actual: \(actual ?? "nil")")
        }
    }
    
    // Summary
    print("\nTest Results: \(passedTests)/\(tests.count) tests passed")
    if passedTests == tests.count {
        print("All tests passed! 🎉")
    } else {
        print("Some tests failed. 😢")
    }
}

// Run the tests
testSecurityErrorDescriptions() 