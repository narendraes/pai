import Foundation
import Combine
import NMSSH

protocol SSHConnectionServiceProtocol {
    var isConnected: Bool { get }
    var connectionStatus: CurrentValueSubject<ConnectionStatus, Never> { get }
    
    func connect(host: String, username: String, password: String?) -> AnyPublisher<Bool, NetworkError>
    func connect(host: String, username: String, privateKey: String) -> AnyPublisher<Bool, NetworkError>
    func disconnect()
    func executeCommand(_ command: String) -> AnyPublisher<String, NetworkError>
}

class SSHConnectionService: SSHConnectionServiceProtocol {
    private var session: NMSSHSession?
    private let queue = DispatchQueue(label: "com.privatehomeai.ssh", qos: .userInitiated)
    
    var isConnected: Bool {
        session?.isConnected ?? false
    }
    
    var connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    
    func connect(host: String, username: String, password: String?) -> AnyPublisher<Bool, NetworkError> {
        return Future<Bool, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.unknown(NSError(domain: "SSHConnectionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))))
                return
            }
            
            self.queue.async {
                self.connectionStatus.send(.connecting)
                
                // Disconnect if already connected
                if self.session?.isConnected == true {
                    self.session?.disconnect()
                }
                
                // Create new session
                self.session = NMSSHSession(host: host, andUsername: username)
                
                guard let session = self.session else {
                    self.connectionStatus.send(.error("Failed to create SSH session"))
                    promise(.failure(NetworkError.sshConnectionFailed("Failed to create SSH session")))
                    return
                }
                
                // Connect to server
                session.connect()
                
                if !session.isConnected {
                    self.connectionStatus.send(.error("Failed to connect to server"))
                    promise(.failure(NetworkError.sshConnectionFailed("Failed to connect to server")))
                    return
                }
                
                // Authenticate
                if let password = password {
                    session.authenticate(withPassword: password)
                } else {
                    session.authenticate(withPassword: "")
                }
                
                if !session.isAuthorized {
                    self.connectionStatus.send(.error("Authentication failed"))
                    promise(.failure(NetworkError.unauthorized))
                    return
                }
                
                self.connectionStatus.send(.connected)
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
    
    func connect(host: String, username: String, privateKey: String) -> AnyPublisher<Bool, NetworkError> {
        return Future<Bool, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.unknown(NSError(domain: "SSHConnectionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))))
                return
            }
            
            self.queue.async {
                self.connectionStatus.send(.connecting)
                
                // Disconnect if already connected
                if self.session?.isConnected == true {
                    self.session?.disconnect()
                }
                
                // Create new session
                self.session = NMSSHSession(host: host, andUsername: username)
                
                guard let session = self.session else {
                    self.connectionStatus.send(.error("Failed to create SSH session"))
                    promise(.failure(NetworkError.sshConnectionFailed("Failed to create SSH session")))
                    return
                }
                
                // Connect to server
                session.connect()
                
                if !session.isConnected {
                    self.connectionStatus.send(.error("Failed to connect to server"))
                    promise(.failure(NetworkError.sshConnectionFailed("Failed to connect to server")))
                    return
                }
                
                // Authenticate with private key
                session.authenticate(withPublicKey: nil, privateKey: privateKey, andPassword: nil)
                
                if !session.isAuthorized {
                    self.connectionStatus.send(.error("Authentication failed"))
                    promise(.failure(NetworkError.unauthorized))
                    return
                }
                
                self.connectionStatus.send(.connected)
                promise(.success(true))
            }
        }.eraseToAnyPublisher()
    }
    
    func disconnect() {
        queue.async { [weak self] in
            guard let self = self, let session = self.session else { return }
            
            if session.isConnected {
                session.disconnect()
            }
            
            self.connectionStatus.send(.disconnected)
        }
    }
    
    func executeCommand(_ command: String) -> AnyPublisher<String, NetworkError> {
        return Future<String, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NetworkError.unknown(NSError(domain: "SSHConnectionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"]))))
                return
            }
            
            self.queue.async {
                guard let session = self.session, session.isConnected, session.isAuthorized else {
                    promise(.failure(NetworkError.sshConnectionFailed("Not connected or authorized")))
                    return
                }
                
                let error = NSErrorPointer(nilLiteral: ())
                let output = session.channel.execute(command, error: error)
                
                if let error = error?.pointee {
                    promise(.failure(NetworkError.requestFailed(error)))
                    return
                }
                
                promise(.success(output ?? ""))
            }
        }.eraseToAnyPublisher()
    }
} 