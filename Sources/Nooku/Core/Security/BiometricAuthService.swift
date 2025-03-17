import Foundation
import LocalAuthentication

/// Service for handling biometric authentication (Face ID / Touch ID)
public class BiometricAuthService {
    /// Shared instance for singleton access
    public static let shared = BiometricAuthService()
    
    /// Biometric authentication context
    private let context = LAContext()
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Check if biometric authentication is available
    /// - Returns: A tuple containing a boolean indicating availability and a string describing the biometric type
    public func biometricAuthAvailable() -> (available: Bool, biometricType: String) {
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
            case .opticID:
                biometricType = "Optic ID"
            @unknown default:
                biometricType = "Unknown"
            }
        }
        
        return (available, biometricType)
    }
    
    /// Authenticate using biometrics
    /// - Parameters:
    ///   - reason: The reason for requesting biometric authentication
    ///   - completion: Completion handler with Result type
    public func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            completion(.failure(NSError(domain: "BiometricAuthService", code: -1)))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "BiometricAuthService", code: -1)))
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