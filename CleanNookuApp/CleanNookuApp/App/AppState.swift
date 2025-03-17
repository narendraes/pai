import Foundation
import Combine
import SwiftUI

/// The main app state for the Private Home AI app
public class AppState: ObservableObject {
    /// Whether the user is authenticated
    @Published public var isAuthenticated: Bool = false
    
    /// Whether the app is connected to the server
    @Published public var isConnected: Bool = false
    
    /// The current connection status
    @Published public var connectionStatus: ConnectionStatus = .disconnected
    
    /// The currently selected tab
    @Published public var selectedTab: TabSelection = .chat
    
    /// Whether to show the jailbreak alert
    @Published public var showJailbreakAlert: Bool = false
    
    /// App settings
    @Published public var settings = AppSettings()
    
    /// Initialize a new app state
    public init() {
        // Setup will be added later
    }
    
    /// Tab selection for the app
    public enum TabSelection: Hashable {
        case chat
        case camera
        case analysis
        case settings
    }
}

// MARK: - App Settings
extension AppState {
    public struct AppSettings {
        public var useDarkMode = true
        public var enableNotifications = true
        public var defaultCameraId: String?
        
        public enum RecordingQuality {
            case low, medium, high
        }
        public var recordingQuality: RecordingQuality = .high
        
        public init() {}
    }
}

// MARK: - Enums
public enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case error(String)
    
    public var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .error(let message): return "Error: \(message)"
        }
    }
}
