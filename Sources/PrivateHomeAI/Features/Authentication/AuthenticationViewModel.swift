import Foundation
import Combine

class AuthenticationViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage = ""
    @Published var isLoading = false
    
    private let keychainService: KeychainServiceProtocol
    private let encryptionService: EncryptionServiceProtocol
    private let sshConnectionService: SSHConnectionServiceProtocol
    private let jailbreakDetectionService: JailbreakDetectionServiceProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        keychainService: KeychainServiceProtocol? = nil,
        encryptionService: EncryptionServiceProtocol? = nil,
        sshConnectionService: SSHConnectionServiceProtocol? = nil,
        jailbreakDetectionService: JailbreakDetectionServiceProtocol? = nil
    ) {
        self.keychainService = keychainService ?? DependencyContainer.shared.keychainService
        self.encryptionService = encryptionService ?? DependencyContainer.shared.encryptionService
        self.sshConnectionService = sshConnectionService ?? DependencyContainer.shared.sshConnectionService
        self.jailbreakDetectionService = jailbreakDetectionService ?? DependencyContainer.shared.jailbreakDetectionService
        
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        sshConnectionService.connectionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                switch status {
                case .connected:
                    self?.isAuthenticated = true
                    self?.isLoading = false
                case .error(let message):
                    self?.errorMessage = message
                    self?.isLoading = false
                case .disconnected:
                    self?.isAuthenticated = false
                    self?.isLoading = false
                case .connecting:
                    self?.isLoading = true
                }
            }
            .store(in: &cancellables)
    }
    
    func authenticate() {
        isLoading = true
        errorMessage = ""
        
        // Check for jailbreak
        if jailbreakDetectionService.isJailbroken() {
            errorMessage = "Device security check failed"
            isLoading = false
            return
        }
        
        // For demo purposes, we'll use a hardcoded host and credentials
        // In a real app, these would be securely stored or obtained from the user
        let host = "localhost"
        let sshUsername = username.isEmpty ? "demo" : username
        let sshPassword = password.isEmpty ? "password" : password
        
        sshConnectionService.connect(host: host, username: sshUsername, password: sshPassword)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                    }
                },
                receiveValue: { [weak self] success in
                    if success {
                        // Store credentials securely
                        self?.storeCredentials(username: sshUsername, password: sshPassword, host: host)
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    private func storeCredentials(username: String, password: String, host: String) {
        do {
            // Generate a secure key for encryption
            let encryptionKey = encryptionService.generateRandomKey(length: 32)
            
            // Store the encryption key in the keychain
            try keychainService.save(key: "encryptionKey", data: Data(encryptionKey.utf8))
            
            // Encrypt and store the credentials
            let credentials = "\(username):\(password)@\(host)"
            if let credentialsData = credentials.data(using: .utf8) {
                let encryptedData = try encryptionService.encrypt(credentialsData, with: encryptionKey)
                try keychainService.save(key: "sshCredentials", data: encryptedData)
            }
        } catch {
            print("Failed to store credentials: \(error)")
        }
    }
    
    func logout() {
        sshConnectionService.disconnect()
        isAuthenticated = false
        username = ""
        password = ""
        
        // Clear stored credentials
        do {
            try keychainService.delete(key: "sshCredentials")
        } catch {
            print("Failed to delete credentials: \(error)")
        }
    }
} 