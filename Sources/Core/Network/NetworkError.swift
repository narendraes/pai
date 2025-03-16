import Foundation

/// Network-related errors
public enum NetworkError: LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case unauthorized
    case serverError(Int)
    case connectionLost
    case sshConnectionFailed(String)
    case timeout
    case unknown(Error)
    case notConnected
    case connectionFailed
    case disconnectionFailed
    case commandExecutionFailed
    case fileTransferFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .connectionLost:
            return "Connection lost"
        case .sshConnectionFailed(let reason):
            return "SSH connection failed: \(reason)"
        case .timeout:
            return "Request timed out"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .notConnected:
            return "Not connected to server"
        case .connectionFailed:
            return "Failed to establish connection"
        case .disconnectionFailed:
            return "Failed to disconnect"
        case .commandExecutionFailed:
            return "Failed to execute command"
        case .fileTransferFailed:
            return "Failed to transfer file"
        }
    }
} 