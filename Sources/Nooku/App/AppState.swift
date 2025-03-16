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
    public init(
        sshConnectionService: SSHConnectionServiceProtocol? = nil,
        jailbreakDetectionService: JailbreakDetectionServiceProtocol? = nil
    ) {
        self.sshConnectionService = sshConnectionService ?? DependencyContainer.shared.sshConnectionService
        self.jailbreakDetectionService = jailbreakDetectionService ?? DependencyContainer.shared.jailbreakDetectionService
        
        LoggingService.shared.log(category: .startup, level: .info, message: "AppState initialized")
        
        setupObservers()
        checkJailbreak()
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