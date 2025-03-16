import Foundation
import Alamofire

class DependencyContainer {
    // MARK: - Shared Instance
    static let shared = DependencyContainer()
    
    // MARK: - Network Services
    lazy var networkService: NetworkService = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        
        let session = Session(configuration: configuration)
        return AlamofireNetworkService(baseURL: URL(string: "http://localhost:11434")!, session: session)
    }()
    
    lazy var sshConnectionService: SSHConnectionServiceProtocol = {
        return SSHConnectionService.shared
    }()
    
    lazy var ollamaService: OllamaServiceProtocol = {
        return OllamaService(networkService: networkService)
    }()
    
    // MARK: - Security Services
    lazy var keychainService: KeychainServiceProtocol = {
        return KeychainService()
    }()
    
    lazy var encryptionService: EncryptionServiceProtocol = {
        return EncryptionService()
    }()
    
    lazy var jailbreakDetectionService: JailbreakDetectionServiceProtocol = {
        return JailbreakDetectionService()
    }()
    
    // MARK: - Authentication
    lazy var authenticationViewModel: AuthenticationViewModel = {
        return AuthenticationViewModel()
    }()
    
    // MARK: - Private Init
    private init() {}
} 