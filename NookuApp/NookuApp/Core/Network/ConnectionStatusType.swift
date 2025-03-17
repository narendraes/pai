import Foundation
import SwiftUI

/// Represents the current connection status
public enum ConnectionStatusType: CustomStringConvertible, Equatable {
    case connected
    case disconnected
    case connecting
    case error(String)
    
    public var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .error(let message): return "Error: \(message)"
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
    
    /// Implement Equatable for ConnectionStatusType
    public static func == (lhs: ConnectionStatusType, rhs: ConnectionStatusType) -> Bool {
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