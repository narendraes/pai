import Foundation
import LocalAuthentication

/// Service for handling biometric authentication (Face ID / Touch ID)
class BiometricAuthService {
    /// Shared instance for singleton access
    static let shared = BiometricAuthService()
    
    /// Biometric authentication context
    private let context = LAContext()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Check if biometric authentication is available
    /// - Returns: A tuple containing a boolean indicating availability and a string describing the biometric type
    func biometricAuthAvailable() -> (available: Bool, biometricType: String) {
        var error: NSError?
        
        // Check if biometric authentication is available
        let available = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        
        // Determine biometric type
        var biometricType = "None"
        if available {
            switch context.biometryType {
            case .faceID:
                biometricType = "Face ID"
            case .touchID:
                biometricType = "Touch ID"
            default:
                biometricType = "Biometrics"
            }
        }
        
        return (available, biometricType)
    }
    
    /// Authenticate using biometrics
    /// - Parameters:
    ///   - reason: The reason for authentication to display to the user
    ///   - completion: Callback with authentication result
    func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reset context for new authentication
        context.invalidate()
        
        // Check if biometric authentication is available
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(BiometricError.notAvailable))
            }
            return
        }
        
        // Perform authentication
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(BiometricError.failed))
                }
            }
        }
    }
}

/// Biometric authentication errors
enum BiometricError: Error, LocalizedError {
    case notAvailable
    case failed
    
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .failed:
            return "Biometric authentication failed"
        }
    }
} 