import SwiftUI
import Combine

@main
struct PrivateHomeAIApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    // Check for jailbreak
                    if JailbreakDetectionService.shared.isJailbroken() {
                        appState.showJailbreakAlert = true
                    }
                }
                .alert("Security Warning", isPresented: $appState.showJailbreakAlert) {
                    Button("Exit", role: .destructive) {
                        exit(0)
                    }
                } message: {
                    Text("This device appears to be jailbroken. For security reasons, this app cannot run on jailbroken devices.")
                }
        }
    }
}

class AppState: ObservableObject {
    // Authentication state
    @Published var isAuthenticated = false
    
    // Connection state
    @Published var isConnected = false
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    // Navigation state
    @Published var selectedTab: TabSelection = .chat
    
    // Security state
    @Published var showJailbreakAlert = false
    
    // Services
    private let sshService = SSHService.shared
    private let biometricService = BiometricAuthService.shared
    private let storageService = StorageService.shared
    
    // Initialize app state
    init() {
        // Load authentication state
        isAuthenticated = storageService.retrieveSimple(Bool.self, forKey: "isAuthenticated") ?? false
        
        // Subscribe to SSH connection status
        sshService.$connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.connectionStatus = status
                self?.isConnected = status == .connected
            }
            .store(in: &cancellables)
    }
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Authentication Methods
    
    /// Authenticate with username and password
    /// - Parameters:
    ///   - username: The username
    ///   - password: The password
    ///   - completion: Callback with authentication result
    func authenticate(username: String, password: String, completion: @escaping (Bool) -> Void) {
        // For demo purposes, accept "demo" / "password"
        if username == "demo" && password == "password" {
            // Save credentials securely
            KeychainService.shared.save(value: username, for: "username")
            KeychainService.shared.save(value: password, for: "password")
            
            // Update authentication state
            isAuthenticated = true
            storageService.saveSimple(true, forKey: "isAuthenticated")
            
            completion(true)
        } else {
            completion(false)
        }
    }
    
    /// Authenticate with biometrics
    /// - Parameter completion: Callback with authentication result
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        biometricService.authenticate(reason: "Log in to Private Home AI") { result in
            switch result {
            case .success:
                // Update authentication state
                self.isAuthenticated = true
                self.storageService.saveSimple(true, forKey: "isAuthenticated")
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    /// Log out
    func logout() {
        // Clear authentication state
        isAuthenticated = false
        storageService.saveSimple(false, forKey: "isAuthenticated")
        
        // Disconnect from server
        if isConnected {
            sshService.disconnect()
        }
    }
    
    // MARK: - Connection Methods
    
    /// Connect to the server
    /// - Parameters:
    ///   - host: Server hostname or IP address
    ///   - port: Server port
    ///   - completion: Callback with connection result
    func connectToServer(host: String = "localhost", port: Int = 22, completion: @escaping (Bool) -> Void) {
        // Get credentials from keychain
        guard let username = KeychainService.shared.retrieveString(for: "username"),
              let password = KeychainService.shared.retrieveString(for: "password") else {
            completion(false)
            return
        }
        
        // Connect to server
        sshService.connect(host: host, port: port, username: username, password: password) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    /// Disconnect from the server
    func disconnectFromServer() {
        sshService.disconnect()
    }
}

/// Tab selection options
enum TabSelection {
    case chat
    case cameras
    case analysis
    case settings
}

enum ConnectionStatus {
    case connecting
    case connected
    case disconnected
    case error(String)
    
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