import Foundation

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