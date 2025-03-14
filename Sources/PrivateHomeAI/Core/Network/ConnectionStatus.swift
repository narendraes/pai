import SwiftUI

/// Represents the current connection status to the server
enum ConnectionStatus {
    case connecting
    case connected
    case disconnected
    case error(String)
    
    /// Human-readable description of the connection status
    var description: String {
        switch self {
        case .connecting:
            return "Connecting..."
        case .connected:
            return "Connected"
        case .disconnected:
            return "Disconnected"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    /// Icon name for the connection status
    var iconName: String {
        switch self {
        case .connecting:
            return "arrow.clockwise"
        case .connected:
            return "checkmark.circle.fill"
        case .disconnected:
            return "xmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    /// Color representing the connection status
    var color: Color {
        switch self {
        case .connecting:
            return .yellow
        case .connected:
            return .green
        case .disconnected:
            return .gray
        case .error:
            return .red
        }
    }
} 