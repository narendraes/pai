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
    @Published public var connectionStatus: ConnectionStatusType = .disconnected
    
    /// The currently selected tab
    @Published public var selectedTab: TabSelection = .chat
    
    /// Whether to show the jailbreak alert
    @Published public var showJailbreakAlert: Bool = false
    
    /// The current screen
    @Published public var currentScreen: Screen = .home
    
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
    
    // MARK: - Public Methods
    func connect() {
        connectionStatus = .connecting
        
        // Simulate connection process
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.connectionStatus = .connected
        }
    }
    
    func disconnect() {
        connectionStatus = .disconnected
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

// MARK: - Enums
enum Screen {
    case home
    case chat
    case camera
    case mediaAnalysis
    case settings
}

enum ConnectionStatusType {
    case disconnected
    case connecting
    case connected
    case error
} 