import XCTest
@testable import PrivateHomeAI

final class KeychainServiceTests: XCTestCase {
    var keychainService: KeychainService!
    let testService = "com.privatehomeai.tests"
    
    override func setUp() {
        super.setUp()
        keychainService = KeychainService(service: testService)
        
        // Clean up any leftover test data
        try? keychainService.clear()
    }
    
    override func tearDown() {
        try? keychainService.clear()
        keychainService = nil
        super.tearDown()
    }
    
    func testSaveAndLoadData() throws {
        // Given
        let key = "testKey"
        let testData = "test data".data(using: .utf8)!
        
        // When
        try keychainService.save(key: key, data: testData)
        let loadedData = try keychainService.load(key: key)
        
        // Then
        XCTAssertNotNil(loadedData)
        XCTAssertEqual(loadedData, testData)
    }
    
    func testLoadNonExistentKey() throws {
        // Given
        let key = "nonExistentKey"
        
        // When
        let loadedData = try keychainService.load(key: key)
        
        // Then
        XCTAssertNil(loadedData)
    }
    
    func testDeleteData() throws {
        // Given
        let key = "testKey"
        let testData = "test data".data(using: .utf8)!
        try keychainService.save(key: key, data: testData)
        
        // When
        try keychainService.delete(key: key)
        let loadedData = try keychainService.load(key: key)
        
        // Then
        XCTAssertNil(loadedData)
    }
    
    func testClearAllData() throws {
        // Given
        let key1 = "testKey1"
        let key2 = "testKey2"
        let testData = "test data".data(using: .utf8)!
        
        try keychainService.save(key: key1, data: testData)
        try keychainService.save(key: key2, data: testData)
        
        // When
        try keychainService.clear()
        let loadedData1 = try keychainService.load(key: key1)
        let loadedData2 = try keychainService.load(key: key2)
        
        // Then
        XCTAssertNil(loadedData1)
        XCTAssertNil(loadedData2)
    }
    
    func testUpdateExistingData() throws {
        // Given
        let key = "testKey"
        let initialData = "initial data".data(using: .utf8)!
        let updatedData = "updated data".data(using: .utf8)!
        
        // When
        try keychainService.save(key: key, data: initialData)
        try keychainService.save(key: key, data: updatedData)
        let loadedData = try keychainService.load(key: key)
        
        // Then
        XCTAssertEqual(loadedData, updatedData)
    }
    
    func testSecurityErrorLocalization() {
        // Given
        let testError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When & Then
        XCTAssertEqual(SecurityError.encryptionFailed(testError).errorDescription, "Encryption failed: Test error")
        XCTAssertEqual(SecurityError.decryptionFailed(testError).errorDescription, "Decryption failed: Test error")
        XCTAssertEqual(SecurityError.keychainError(-25300).errorDescription, "Keychain error with status: -25300")
        XCTAssertEqual(SecurityError.dataConversionFailed.errorDescription, "Failed to convert data")
        XCTAssertEqual(SecurityError.invalidKey.errorDescription, "Invalid encryption key")
        XCTAssertEqual(SecurityError.jailbreakDetected.errorDescription, "Device jailbreak detected")
        XCTAssertEqual(SecurityError.biometricAuthFailed.errorDescription, "Biometric authentication failed")
        XCTAssertEqual(SecurityError.unknown(testError).errorDescription, "Unknown security error: Test error")
    }
} 