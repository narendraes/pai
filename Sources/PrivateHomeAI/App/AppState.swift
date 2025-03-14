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
    
    /// Initialize a new app state
    public init() {
        LoggingService.shared.log(category: .startup, level: .info, message: "AppState initialized")
    }
    
    /// Connection status for the app
    public enum ConnectionStatus: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)
        
        /// A description of the connection status
        public var description: String {
            switch self {
            case .disconnected:
                return "Disconnected"
            case .connecting:
                return "Connecting..."
            case .connected:
                return "Connected"
            case .error(let message):
                return "Error: \(message)"
            }
        }
        
        /// The icon name for the connection status
        public var iconName: String {
            switch self {
            case .disconnected:
                return "wifi.slash"
            case .connecting:
                return "wifi.exclamationmark"
            case .connected:
                return "wifi"
            case .error:
                return "exclamationmark.triangle"
            }
        }
        
        /// The color for the connection status
        public var color: Color {
            switch self {
            case .disconnected:
                return .red
            case .connecting:
                return .yellow
            case .connected:
                return .green
            case .error:
                return .red
            }
        }
    }
    
    /// Tab selection for the app
    public enum TabSelection: Hashable {
        case chat
        case camera
        case analysis
        case settings
    }
    
    // App settings
    @Published var settings = AppSettings()
    
    // Services
    private let sshConnectionService: SSHConnectionServiceProtocol
    private let jailbreakDetectionService: JailbreakDetectionServiceProtocol
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init(
        sshConnectionService: SSHConnectionServiceProtocol? = nil,
        jailbreakDetectionService: JailbreakDetectionServiceProtocol? = nil
    ) {
        self.sshConnectionService = sshConnectionService ?? DependencyContainer.shared.sshConnectionService
        self.jailbreakDetectionService = jailbreakDetectionService ?? DependencyContainer.shared.jailbreakDetectionService
        
        setupObservers()
        checkJailbreak()
    }
    
    private func setupObservers() {
        // Observe SSH connection status
        sshConnectionService.connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
                
                switch status {
                case .connected:
                    self?.isConnected = true
                case .disconnected, .error:
                    self?.isConnected = false
                case .connecting:
                    // Keep current connection state
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkJailbreak() {
        if jailbreakDetectionService.isJailbroken() {
            // In a real app, you might want to take more drastic action
            // For now, we'll just log it
            print("WARNING: Jailbreak detected!")
        }
    }
}

struct AppSettings {
    var useDarkMode = true
    var enableNotifications = true
    var defaultCameraId: String?
    var recordingQuality: RecordingQuality = .high
    
    enum RecordingQuality {
        case low, medium, high
    }
} 