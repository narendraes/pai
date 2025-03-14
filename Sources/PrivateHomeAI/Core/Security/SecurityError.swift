import Foundation

/// Security-related errors
enum SecurityError: Error, LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case keychainError(OSStatus)
    case dataConversionFailed
    case invalidKey
    case jailbreakDetected
    case biometricAuthFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .dataConversionFailed:
            return "Failed to convert data"
        case .invalidKey:
            return "Invalid encryption key"
        case .jailbreakDetected:
            return "Jailbreak detected"
        case .biometricAuthFailed:
            return "Biometric authentication failed"
        case .unknown:
            return "Unknown security error"
        }
    }
} 