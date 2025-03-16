import XCTest
import Combine
@testable import Nooku

final class AuthenticationViewModelTests: XCTestCase {
    var viewModel: AuthenticationViewModel!
    var mockKeychainService: MockKeychainService!
    var mockEncryptionService: MockEncryptionService!
    var mockSSHConnectionService: MockSSHConnectionService!
    var mockJailbreakDetectionService: MockJailbreakDetectionService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockKeychainService = MockKeychainService()
        mockEncryptionService = MockEncryptionService()
        mockSSHConnectionService = MockSSHConnectionService()
        mockJailbreakDetectionService = MockJailbreakDetectionService(shouldDetectJailbreak: false)
        
        viewModel = AuthenticationViewModel(
            keychainService: mockKeychainService,
            encryptionService: mockEncryptionService,
            sshConnectionService: mockSSHConnectionService,
            jailbreakDetectionService: mockJailbreakDetectionService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockKeychainService = nil
        mockEncryptionService = nil
        mockSSHConnectionService = nil
        mockJailbreakDetectionService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testSuccessfulAuthentication() {
        // Given
        let expectation = XCTestExpectation(description: "Authentication success")
        let username = "testuser"
        let password = "testpassword"
        let host = "localhost"
        let port = 22
        
        mockSSHConnectionService.shouldSucceed = true
        
        // When
        viewModel.authenticate(username: username, password: password, host: host, port: port)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.viewModel.isAuthenticated)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertTrue(self.mockKeychainService.saveWasCalled)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testFailedAuthentication() {
        // Given
        let expectation = XCTestExpectation(description: "Authentication failure")
        let username = "testuser"
        let password = "wrongpassword"
        let host = "localhost"
        let port = 22
        
        mockSSHConnectionService.shouldSucceed = false
        mockSSHConnectionService.errorToReturn = NetworkError.unauthorized
        
        // When
        viewModel.authenticate(username: username, password: password, host: host, port: port)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.isAuthenticated)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertFalse(self.mockKeychainService.saveWasCalled)
            XCTAssertFalse(self.viewModel.errorMessage.isEmpty)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testJailbreakDetection() {
        // Given
        let expectation = XCTestExpectation(description: "Jailbreak detection")
        let username = "testuser"
        let password = "testpassword"
        let host = "localhost"
        let port = 22
        
        // Configure mock to detect jailbreak
        mockJailbreakDetectionService = MockJailbreakDetectionService(shouldDetectJailbreak: true)
        viewModel = AuthenticationViewModel(
            keychainService: mockKeychainService,
            encryptionService: mockEncryptionService,
            sshConnectionService: mockSSHConnectionService,
            jailbreakDetectionService: mockJailbreakDetectionService
        )
        
        // When
        viewModel.authenticate(username: username, password: password, host: host, port: port)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.viewModel.isAuthenticated)
            XCTAssertFalse(self.viewModel.isLoading)
            XCTAssertEqual(self.viewModel.errorMessage, "Device security check failed")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLogout() {
        // Given
        viewModel.isAuthenticated = true
        
        // When
        viewModel.logout()
        
        // Then
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(mockSSHConnectionService.disconnectWasCalled)
        XCTAssertTrue(mockKeychainService.deleteWasCalled)
    }
    
    func testConnectionStatusUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Connection status updates")
        
        // When
        mockSSHConnectionService.connectionStatus.send(.connecting)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.viewModel.isLoading)
            
            // When
            self.mockSSHConnectionService.connectionStatus.send(.connected)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertTrue(self.viewModel.isAuthenticated)
                XCTAssertFalse(self.viewModel.isLoading)
                
                // When
                self.mockSSHConnectionService.connectionStatus.send(.error("Test error"))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Then
                    XCTAssertEqual(self.viewModel.errorMessage, "Test error")
                    XCTAssertFalse(self.viewModel.isLoading)
                    
                    // When
                    self.mockSSHConnectionService.connectionStatus.send(.disconnected)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Then
                        XCTAssertFalse(self.viewModel.isAuthenticated)
                        XCTAssertFalse(self.viewModel.isLoading)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Mock Services
class MockKeychainService: KeychainServiceProtocol {
    var saveWasCalled = false
    var loadWasCalled = false
    var deleteWasCalled = false
    var clearWasCalled = false
    
    var dataToReturn: Data?
    var errorToThrow: Error?
    
    func save(key: String, data: Data) throws {
        saveWasCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func load(key: String) throws -> Data? {
        loadWasCalled = true
        if let error = errorToThrow {
            throw error
        }
        return dataToReturn
    }
    
    func delete(key: String) throws {
        deleteWasCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
    
    func clear() throws {
        clearWasCalled = true
        if let error = errorToThrow {
            throw error
        }
    }
}

class MockEncryptionService: EncryptionServiceProtocol {
    var encryptWasCalled = false
    var decryptWasCalled = false
    var generateKeyWasCalled = false
    var hashPasswordWasCalled = false
    
    var dataToReturn: Data = Data()
    var keyToReturn: String = "mock-key-12345"
    var hashToReturn: String = "mock-hash-12345"
    var errorToThrow: Error?
    
    func encrypt(_ data: Data, with key: String) throws -> Data {
        encryptWasCalled = true
        if let error = errorToThrow {
            throw error
        }
        return dataToReturn
    }
    
    func decrypt(_ data: Data, with key: String) throws -> Data {
        decryptWasCalled = true
        if let error = errorToThrow {
            throw error
        }
        return dataToReturn
    }
    
    func generateRandomKey(length: Int) -> String {
        generateKeyWasCalled = true
        return keyToReturn
    }
    
    func hashPassword(_ password: String, salt: String) throws -> String {
        hashPasswordWasCalled = true
        if let error = errorToThrow {
            throw error
        }
        return hashToReturn
    }
}

class MockSSHConnectionService: SSHConnectionServiceProtocol {
    var isConnected = false
    var connectionStatus = CurrentValueSubject<ConnectionStatus, Never>(.disconnected)
    
    var connectWasCalled = false
    var disconnectWasCalled = false
    var executeCommandWasCalled = false
    
    var shouldSucceed = true
    var errorToReturn: NetworkError?
    var commandOutputToReturn = ""
    
    func connect(host: String, username: String, password: String?) -> AnyPublisher<Bool, NetworkError> {
        connectWasCalled = true
        
        if shouldSucceed {
            return Just(true)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.unauthorized)
                .eraseToAnyPublisher()
        }
    }
    
    func connect(host: String, username: String, privateKey: String) -> AnyPublisher<Bool, NetworkError> {
        connectWasCalled = true
        
        if shouldSucceed {
            return Just(true)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.unauthorized)
                .eraseToAnyPublisher()
        }
    }
    
    func disconnect() {
        disconnectWasCalled = true
        isConnected = false
    }
    
    func executeCommand(_ command: String) -> AnyPublisher<String, NetworkError> {
        executeCommandWasCalled = true
        
        if shouldSucceed {
            return Just(commandOutputToReturn)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.requestFailed(NSError(domain: "test", code: 0, userInfo: nil)))
                .eraseToAnyPublisher()
        }
    }
} 