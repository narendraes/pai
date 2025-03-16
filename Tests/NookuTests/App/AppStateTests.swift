import XCTest
import Combine
@testable import Nooku

final class AppStateTests: XCTestCase {
    var appState: AppState!
    var mockSSHConnectionService: MockSSHConnectionService!
    var mockJailbreakDetectionService: MockJailbreakDetectionService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockSSHConnectionService = MockSSHConnectionService()
        mockJailbreakDetectionService = MockJailbreakDetectionService(shouldDetectJailbreak: false)
        
        appState = AppState(
            sshConnectionService: mockSSHConnectionService,
            jailbreakDetectionService: mockJailbreakDetectionService
        )
    }
    
    override func tearDown() {
        appState = nil
        mockSSHConnectionService = nil
        mockJailbreakDetectionService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testInitialState() {
        // Then
        XCTAssertFalse(appState.isAuthenticated)
        XCTAssertFalse(appState.isConnectedToMac)
        XCTAssertEqual(appState.connectionStatus, .disconnected)
        XCTAssertTrue(appState.settings.useDarkMode)
        XCTAssertTrue(appState.settings.enableNotifications)
        XCTAssertEqual(appState.settings.recordingQuality, .high)
    }
    
    func testConnectionStatusUpdates() {
        // Given
        let expectation = XCTestExpectation(description: "Connection status updates")
        
        // When
        mockSSHConnectionService.connectionStatus.send(.connecting)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.appState.connectionStatus, .connecting)
            XCTAssertFalse(self.appState.isConnectedToMac)
            
            // When
            self.mockSSHConnectionService.connectionStatus.send(.connected)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertEqual(self.appState.connectionStatus, .connected)
                XCTAssertTrue(self.appState.isConnectedToMac)
                
                // When
                self.mockSSHConnectionService.connectionStatus.send(.error("Test error"))
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // Then
                    XCTAssertEqual(self.appState.connectionStatus, .error("Test error"))
                    XCTAssertFalse(self.appState.isConnectedToMac)
                    
                    // When
                    self.mockSSHConnectionService.connectionStatus.send(.disconnected)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        // Then
                        XCTAssertEqual(self.appState.connectionStatus, .disconnected)
                        XCTAssertFalse(self.appState.isConnectedToMac)
                        expectation.fulfill()
                    }
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testJailbreakDetection() {
        // Given
        mockJailbreakDetectionService = MockJailbreakDetectionService(shouldDetectJailbreak: true)
        
        // When
        appState = AppState(
            sshConnectionService: mockSSHConnectionService,
            jailbreakDetectionService: mockJailbreakDetectionService
        )
        
        // Then
        // We can't directly test the print statement, but we can verify the method was called
        XCTAssertTrue(mockJailbreakDetectionService.isJailbrokenWasCalled)
    }
    
    func testSettingsModification() {
        // When
        appState.settings.useDarkMode = false
        appState.settings.enableNotifications = false
        appState.settings.recordingQuality = .low
        appState.settings.defaultCameraId = "camera1"
        
        // Then
        XCTAssertFalse(appState.settings.useDarkMode)
        XCTAssertFalse(appState.settings.enableNotifications)
        XCTAssertEqual(appState.settings.recordingQuality, .low)
        XCTAssertEqual(appState.settings.defaultCameraId, "camera1")
    }
}

// Add this to the MockJailbreakDetectionService
extension MockJailbreakDetectionService {
    var isJailbrokenWasCalled = false
    
    override func isJailbroken() -> Bool {
        isJailbrokenWasCalled = true
        return super.isJailbroken()
    }
} 