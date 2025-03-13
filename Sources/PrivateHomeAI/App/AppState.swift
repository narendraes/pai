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
    
    // Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Setup observers for state changes
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