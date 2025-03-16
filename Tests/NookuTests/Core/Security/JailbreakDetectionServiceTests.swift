import XCTest
@testable import Nooku

final class JailbreakDetectionServiceTests: XCTestCase {
    var jailbreakDetectionService: JailbreakDetectionService!
    
    override func setUp() {
        super.setUp()
        jailbreakDetectionService = JailbreakDetectionService()
    }
    
    override func tearDown() {
        jailbreakDetectionService = nil
        super.tearDown()
    }
    
    func testIsJailbroken() {
        // This is a basic test to ensure the method runs without crashing
        // In a real environment, we can't reliably test for jailbreak detection
        // as it depends on the device state
        
        // When
        let isJailbroken = jailbreakDetectionService.isJailbroken()
        
        // Then
        // On simulator, this should always be false
        #if targetEnvironment(simulator)
        XCTAssertFalse(isJailbroken, "Simulator should never be detected as jailbroken")
        #else
        // On a real device, we can't make assumptions about the jailbreak state
        // So we just ensure the method runs without crashing
        _ = isJailbroken
        #endif
    }
    
    // Test the mock implementation for development purposes
    func testMockJailbreakDetection() {
        // Given
        let mockService = MockJailbreakDetectionService(shouldDetectJailbreak: true)
        
        // When
        let isJailbroken = mockService.isJailbroken()
        
        // Then
        XCTAssertTrue(isJailbroken, "Mock service should detect jailbreak when configured to do so")
        
        // Given
        let mockService2 = MockJailbreakDetectionService(shouldDetectJailbreak: false)
        
        // When
        let isJailbroken2 = mockService2.isJailbroken()
        
        // Then
        XCTAssertFalse(isJailbroken2, "Mock service should not detect jailbreak when configured not to")
    }
}

// MARK: - Mock Jailbreak Detection Service
class MockJailbreakDetectionService: JailbreakDetectionServiceProtocol {
    private let shouldDetectJailbreak: Bool
    
    init(shouldDetectJailbreak: Bool) {
        self.shouldDetectJailbreak = shouldDetectJailbreak
    }
    
    func isJailbroken() -> Bool {
        return shouldDetectJailbreak
    }
} 