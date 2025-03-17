import Foundation
import Logging
import CryptoSwift

/// Manages SSH server functionality for secure connections
public class SSHServer {
    // MARK: - Properties
    
    /// Shared singleton instance
    public static let shared = SSHServer()
    
    /// Logger for SSH operations
    private let logger = Logger(label: "com.nooku.macserver.ssh")
    
    /// Server status
    private(set) public var isRunning = false
    
    /// Server port
    private(set) public var port: UInt16 = 2222
    
    /// Authorized keys for authentication
    private var authorizedKeys: [AuthorizedKey] = []
    
    /// Active connections
    private var activeConnections: [UUID: SSHConnection] = [:]
    
    /// Queue for synchronizing access to connections
    private let connectionQueue = DispatchQueue(label: "com.nooku.macserver.ssh.connections", attributes: .concurrent)
    
    // MARK: - Initialization
    
    private init() {
        logger.info("SSHServer initialized")
        loadAuthorizedKeys()
    }
    
    // MARK: - Public Methods
    
    /// Start the SSH server
    /// - Parameter port: Port to listen on (default: 2222)
    /// - Returns: True if successfully started, false otherwise
    public func start(port: UInt16 = 2222) -> Bool {
        logger.info("Starting SSH server on port \(port)")
        
        guard !isRunning else {
            logger.warning("SSH server already running")
            return true
        }
        
        // In a real implementation, this would initialize an SSH server library
        // For this example, we'll simulate the server functionality
        
        self.port = port
        isRunning = true
        
        logger.info("SSH server started on port \(port)")
        return true
    }
    
    /// Stop the SSH server
    public func stop() {
        logger.info("Stopping SSH server")
        
        guard isRunning else {
            logger.warning("SSH server not running")
            return
        }
        
        // Close all active connections
        connectionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            for (_, connection) in self.activeConnections {
                connection.close()
            }
            
            self.activeConnections.removeAll()
        }
        
        isRunning = false
        logger.info("SSH server stopped")
    }
    
    /// Add a new authorized key for authentication
    /// - Parameters:
    ///   - key: The public key data
    ///   - comment: Optional comment for the key
    /// - Returns: True if successfully added, false otherwise
    public func addAuthorizedKey(key: Data, comment: String? = nil) -> Bool {
        let newKey = AuthorizedKey(
            id: UUID(),
            keyData: key,
            comment: comment,
            createdAt: Date()
        )
        
        authorizedKeys.append(newKey)
        saveAuthorizedKeys()
        
        logger.info("Added authorized key: \(newKey.id)")
        return true
    }
    
    /// Remove an authorized key
    /// - Parameter id: ID of the key to remove
    /// - Returns: True if successfully removed, false otherwise
    public func removeAuthorizedKey(id: UUID) -> Bool {
        let initialCount = authorizedKeys.count
        authorizedKeys.removeAll { $0.id == id }
        
        if authorizedKeys.count < initialCount {
            saveAuthorizedKeys()
            logger.info("Removed authorized key: \(id)")
            return true
        } else {
            logger.warning("Authorized key not found: \(id)")
            return false
        }
    }
    
    /// Get all authorized keys
    /// - Returns: Array of authorized keys
    public func getAuthorizedKeys() -> [AuthorizedKey] {
        return authorizedKeys
    }
    
    /// Get information about active connections
    /// - Returns: Array of connection information
    public func getActiveConnections() -> [ConnectionInfo] {
        var connections: [ConnectionInfo] = []
        
        connectionQueue.sync {
            connections = activeConnections.values.map { connection in
                ConnectionInfo(
                    id: connection.id,
                    clientAddress: connection.clientAddress,
                    username: connection.username,
                    connectedAt: connection.connectedAt,
                    lastActivity: connection.lastActivity
                )
            }
        }
        
        return connections
    }
    
    // MARK: - Private Methods
    
    private func loadAuthorizedKeys() {
        // In a real implementation, this would load keys from a secure storage
        // For this example, we'll use a simulated storage
        
        let keysURL = getAuthorizedKeysURL()
        
        if FileManager.default.fileExists(atPath: keysURL.path) {
            do {
                let data = try Data(contentsOf: keysURL)
                let decoder = JSONDecoder()
                authorizedKeys = try decoder.decode([AuthorizedKey].self, from: data)
                logger.info("Loaded \(authorizedKeys.count) authorized keys")
            } catch {
                logger.error("Failed to load authorized keys: \(error)")
                authorizedKeys = []
            }
        } else {
            logger.info("No authorized keys file found, starting with empty list")
            authorizedKeys = []
        }
    }
    
    private func saveAuthorizedKeys() {
        // In a real implementation, this would save keys to a secure storage
        // For this example, we'll use a simulated storage
        
        let keysURL = getAuthorizedKeysURL()
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(authorizedKeys)
            try data.write(to: keysURL)
            logger.info("Saved \(authorizedKeys.count) authorized keys")
        } catch {
            logger.error("Failed to save authorized keys: \(error)")
        }
    }
    
    private func getAuthorizedKeysURL() -> URL {
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let nookuDir = appSupportURL.appendingPathComponent("Nooku", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: nookuDir.path) {
            try? FileManager.default.createDirectory(at: nookuDir, withIntermediateDirectories: true)
        }
        
        return nookuDir.appendingPathComponent("authorized_keys.json")
    }
    
    /// Simulate a new connection (for testing purposes)
    /// - Parameters:
    ///   - clientAddress: Client IP address
    ///   - username: Username for the connection
    /// - Returns: Connection ID
    internal func simulateNewConnection(clientAddress: String, username: String) -> UUID {
        let connection = SSHConnection(
            id: UUID(),
            clientAddress: clientAddress,
            username: username,
            connectedAt: Date(),
            lastActivity: Date()
        )
        
        connectionQueue.async(flags: .barrier) { [weak self] in
            self?.activeConnections[connection.id] = connection
        }
        
        logger.info("New connection from \(clientAddress) as \(username): \(connection.id)")
        return connection.id
    }
}

// MARK: - SSH Connection

/// Represents an active SSH connection
class SSHConnection {
    // MARK: - Properties
    
    /// Unique identifier for the connection
    let id: UUID
    
    /// Client IP address
    let clientAddress: String
    
    /// Username for the connection
    let username: String
    
    /// Time when the connection was established
    let connectedAt: Date
    
    /// Time of last activity on the connection
    private(set) var lastActivity: Date
    
    /// Flag indicating if the connection is active
    private(set) var isActive = true
    
    // MARK: - Initialization
    
    init(id: UUID, clientAddress: String, username: String, connectedAt: Date, lastActivity: Date) {
        self.id = id
        self.clientAddress = clientAddress
        self.username = username
        self.connectedAt = connectedAt
        self.lastActivity = lastActivity
    }
    
    // MARK: - Methods
    
    /// Update the last activity time
    func updateActivity() {
        lastActivity = Date()
    }
    
    /// Close the connection
    func close() {
        isActive = false
    }
}

// MARK: - Authorized Key

/// Represents an authorized public key for SSH authentication
public struct AuthorizedKey: Codable {
    /// Unique identifier for the key
    public let id: UUID
    
    /// Public key data
    public let keyData: Data
    
    /// Optional comment for the key
    public let comment: String?
    
    /// Time when the key was added
    public let createdAt: Date
    
    public init(id: UUID, keyData: Data, comment: String?, createdAt: Date) {
        self.id = id
        self.keyData = keyData
        self.comment = comment
        self.createdAt = createdAt
    }
}

// MARK: - Connection Info

/// Information about an active SSH connection
public struct ConnectionInfo: Codable {
    public let id: UUID
    public let clientAddress: String
    public let username: String
    public let connectedAt: Date
    public let lastActivity: Date
    
    public init(id: UUID, clientAddress: String, username: String, connectedAt: Date, lastActivity: Date) {
        self.id = id
        self.clientAddress = clientAddress
        self.username = username
        self.connectedAt = connectedAt
        self.lastActivity = lastActivity
    }
} 