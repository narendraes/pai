import Foundation
import Combine
import SwiftUI

// Import app types
@_exported import enum PrivateHomeAI.ConnectionStatus

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
    
    /// Initialize a new app state
    public init() {
        setupServices()
    }
    
    /// Tab selection for the app
    public enum TabSelection: Hashable {
        case chat
        case camera
        case analysis
        case settings
    }
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Methods
    private func setupServices() {
        // Observe SSH connection status
        SSHService.shared.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
                self?.isConnected = status == .connected
            }
            .store(in: &cancellables)
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
    
    @Published public var settings = AppSettings()
} 