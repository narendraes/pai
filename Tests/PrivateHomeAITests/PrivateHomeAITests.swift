import XCTest
@testable import PrivateHomeAI

final class PrivateHomeAITests: XCTestCase {
    func testEncryptionService() throws {
        let encryptionService = EncryptionService.shared
        
        // Generate a key if needed
        if !encryptionService.hasEncryptionKey() {
            XCTAssertTrue(encryptionService.generateEncryptionKey())
        }
        
        // Test string encryption/decryption
        let originalString = "This is a test string for encryption"
        
        guard let encryptedString = encryptionService.encryptString(originalString) else {
            XCTFail("Failed to encrypt string")
            return
        }
        
        guard let decryptedString = encryptionService.decryptString(encryptedString) else {
            XCTFail("Failed to decrypt string")
            return
        }
        
        XCTAssertEqual(originalString, decryptedString, "Decrypted string should match original")
    }
    
    func testKeychain() throws {
        let keychainService = KeychainService.shared
        
        // Test saving and retrieving a string
        let testKey = "testKey"
        let testValue = "testValue"
        
        XCTAssertTrue(keychainService.save(value: testValue, for: testKey))
        XCTAssertEqual(keychainService.retrieveString(for: testKey), testValue)
        
        // Test deleting a value
        XCTAssertTrue(keychainService.delete(for: testKey))
        XCTAssertNil(keychainService.retrieveString(for: testKey))
    }
    
    func testStorageService() throws {
        let storageService = StorageService.shared
        
        // Test saving and retrieving a simple value
        let testKey = "testBoolKey"
        let testValue = true
        
        storageService.saveSimple(testValue, forKey: testKey)
        let retrievedValue = storageService.retrieveSimple(Bool.self, forKey: testKey)
        
        XCTAssertEqual(retrievedValue, testValue)
        
        // Test removing a value
        storageService.remove(forKey: testKey)
        let removedValue = storageService.retrieveSimple(Bool.self, forKey: testKey)
        
        XCTAssertNil(removedValue)
    }
} 