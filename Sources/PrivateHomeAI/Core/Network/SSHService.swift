import Foundation
import Combine

/// Service for managing SSH connections to the home server
class SSHService: ObservableObject {
    /// Shared instance
    static let shared = SSHService()
    
    /// Current connection status
    @Published var connectionStatus: ConnectionStatus = .disconnected
    
    /// Connection timeout in seconds
    private let connectionTimeout: TimeInterval = 10.0
    
    /// Connection retry count
    private let maxRetryCount = 3
    
    /// Current retry count
    private var currentRetryCount = 0
    
    /// Timer for connection timeout
    private var connectionTimer: Timer?
    
    /// Private initializer for singleton
    private init() {}
    
    /// Connect to SSH server
    /// - Parameters:
    ///   - host: Server hostname or IP address
    ///   - port: Server port
    ///   - username: Username for authentication
    ///   - password: Password for authentication
    ///   - completion: Callback with connection result
    func connect(host: String, port: Int, username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reset retry count
        currentRetryCount = 0
        
        // Update status
        connectionStatus = .connecting
        
        // Start connection timer
        startConnectionTimer()
        
        // Simulate connection process
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 2.0)
            
            // Simulate connection success (90% chance)
            let success = Double.random(in: 0...1) > 0.1
            
            DispatchQueue.main.async {
                // Stop timer
                self.stopConnectionTimer()
                
                if success {
                    // Connection successful
                    self.connectionStatus = .connected
                    completion(.success(()))
                } else {
                    // Connection failed
                    self.handleConnectionFailure(host: host, port: port, username: username, password: password, completion: completion)
                }
            }
        }
    }
    
    /// Disconnect from SSH server
    func disconnect() {
        // Update status
        connectionStatus = .disconnected
        
        // Stop timer
        stopConnectionTimer()
    }
    
    /// Execute command on SSH server
    /// - Parameters:
    ///   - command: Command to execute
    ///   - completion: Callback with command result
    func executeCommand(_ command: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Check if connected
        guard connectionStatus == .connected else {
            completion(.failure(NetworkError.notConnected))
            return
        }
        
        // Simulate command execution
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 0.5)
            
            // Simulate command output
            let output: String
            
            if command.contains("ls") {
                output = "file1.txt\nfile2.txt\nconfig.json\ndata.db"
            } else if command.contains("cat") {
                output = "Content of the requested file."
            } else if command.contains("ps") {
                output = "PID TTY          TIME CMD\n1234 ?        00:00:01 homeai\n2345 ?        00:00:00 nginx\n3456 ?        00:00:02 python"
            } else {
                output = "Command executed successfully."
            }
            
            DispatchQueue.main.async {
                completion(.success(output))
            }
        }
    }
    
    /// Upload file to SSH server
    /// - Parameters:
    ///   - localPath: Local file path
    ///   - remotePath: Remote file path
    ///   - completion: Completion handler
    func uploadFile(localPath: String, remotePath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if connected
        guard connectionStatus == .connected else {
            completion(.failure(NetworkError.notConnected))
            return
        }
        
        // Simulate file upload
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: Double.random(in: 0.5...1.5))
            
            // Simulate success/failure
            let success = Double.random(in: 0...1) > 0.05
            
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkError.fileTransferFailed))
                }
            }
        }
    }
    
    /// Download file from SSH server
    /// - Parameters:
    ///   - remotePath: Remote file path
    ///   - localPath: Local file path
    ///   - completion: Completion handler
    func downloadFile(remotePath: String, localPath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if connected
        guard connectionStatus == .connected else {
            completion(.failure(NetworkError.notConnected))
            return
        }
        
        // Simulate file download
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: Double.random(in: 0.5...1.5))
            
            // Simulate success/failure
            let success = Double.random(in: 0...1) > 0.05
            
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(NetworkError.fileTransferFailed))
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Handle connection failure
    private func handleConnectionFailure(host: String, port: Int, username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Check if we should retry
        if currentRetryCount < maxRetryCount {
            // Increment retry count
            currentRetryCount += 1
            
            // Update status
            connectionStatus = .connecting
            
            // Retry connection after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.connect(host: host, port: port, username: username, password: password, completion: completion)
            }
        } else {
            // Max retries reached, fail
            connectionStatus = .error("Connection failed after \(maxRetryCount) attempts")
            completion(.failure(NetworkError.connectionFailed))
        }
    }
    
    /// Start connection timeout timer
    private func startConnectionTimer() {
        // Stop existing timer
        stopConnectionTimer()
        
        // Start new timer
        connectionTimer = Timer.scheduledTimer(withTimeInterval: connectionTimeout, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Connection timed out
            if self.connectionStatus == .connecting {
                self.connectionStatus = .error("Connection timed out")
                self.stopConnectionTimer()
            }
        }
    }
    
    /// Stop connection timeout timer
    private func stopConnectionTimer() {
        connectionTimer?.invalidate()
        connectionTimer = nil
    }
} 