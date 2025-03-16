import Foundation
import Combine

public class SSHService: ObservableObject {
    public static let shared = SSHService()
    @Published public var connectionStatus: ConnectionStatus = .disconnected
    
    private init() {}
    
    public func connect(host: String, username: String, password: String) {
        connectionStatus = .connecting
        // TODO: Implement actual SSH connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.connectionStatus = .connected
        }
    }
    
    public func disconnect() {
        connectionStatus = .disconnected
    }
} 