import SwiftUI

/// Represents the current connection status to the server
public enum ConnectionStatus: Equatable {
    case connecting
    case connected
    case disconnected
    case error(String)
    
    /// Human-readable description of the connection status
    public var description: String {
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
    public var iconName: String {
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
    public var color: Color {
        switch self {
        case .connecting:
            return .yellow
        case .connected:
            return .green
        case .disconnected:
            return .red
        case .error:
            return .red
        }
    }
    
    /// Implement Equatable for ConnectionStatus
    public static func == (lhs: ConnectionStatus, rhs: ConnectionStatus) -> Bool {
        switch (lhs, rhs) {
        case (.connecting, .connecting), (.connected, .connected), (.disconnected, .disconnected):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
} 