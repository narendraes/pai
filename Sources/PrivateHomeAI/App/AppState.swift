import Foundation
import Combine

class AppState: ObservableObject {
    // Authentication state
    @Published var isAuthenticated = false
    
    // Connection state
    @Published var isConnectedToMac = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
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
                    self?.isConnectedToMac = true
                case .disconnected, .error:
                    self?.isConnectedToMac = false
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

enum ConnectionStatus {
    case disconnected
    case connecting
    case connected
    case error(String)
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