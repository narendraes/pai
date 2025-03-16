import XCTest
@testable import Nooku

final class EncryptionServiceTests: XCTestCase {
    var encryptionService: EncryptionService!
    
    override func setUp() {
        super.setUp()
        encryptionService = EncryptionService()
    }
    
    override func tearDown() {
        encryptionService = nil
        super.tearDown()
    }
    
    func testEncryptAndDecrypt() throws {
        // Given
        let originalData = "This is a test string to encrypt".data(using: .utf8)!
        let key = encryptionService.generateRandomKey(length: 32)
        
        // When
        let encryptedData = try encryptionService.encrypt(originalData, with: key)
        let decryptedData = try encryptionService.decrypt(encryptedData, with: key)
        
        // Then
        XCTAssertNotEqual(originalData, encryptedData, "Encrypted data should be different from original data")
        XCTAssertEqual(originalData, decryptedData, "Decrypted data should match original data")
    }
    
    func testEncryptionWithInvalidKey() {
        // Given
        let data = "Test data".data(using: .utf8)!
        let invalidKey = ""
        
        // When & Then
        XCTAssertThrowsError(try encryptionService.encrypt(data, with: invalidKey)) { error in
            XCTAssertTrue(error is SecurityError)
            if let securityError = error as? SecurityError {
                XCTAssertEqual(securityError.errorDescription, SecurityError.invalidKey.errorDescription)
            }
        }
    }
    
    func testDecryptionWithInvalidKey() {
        // Given
        let data = "Test data".data(using: .utf8)!
        let validKey = encryptionService.generateRandomKey(length: 32)
        let invalidKey = ""
        
        // When & Then
        do {
            let encryptedData = try encryptionService.encrypt(data, with: validKey)
            
            XCTAssertThrowsError(try encryptionService.decrypt(encryptedData, with: invalidKey)) { error in
                XCTAssertTrue(error is SecurityError)
                if let securityError = error as? SecurityError {
                    XCTAssertEqual(securityError.errorDescription, SecurityError.invalidKey.errorDescription)
                }
            }
        } catch {
            XCTFail("Encryption should not fail: \(error)")
        }
    }
    
    func testDecryptionWithWrongKey() {
        // Given
        let data = "Test data".data(using: .utf8)!
        let correctKey = encryptionService.generateRandomKey(length: 32)
        let wrongKey = encryptionService.generateRandomKey(length: 32)
        
        // When & Then
        do {
            let encryptedData = try encryptionService.encrypt(data, with: correctKey)
            
            XCTAssertThrowsError(try encryptionService.decrypt(encryptedData, with: wrongKey)) { error in
                XCTAssertTrue(error is SecurityError)
                if let securityError = error as? SecurityError {
                    XCTAssertTrue(securityError.errorDescription?.contains("Decryption failed") ?? false)
                }
            }
        } catch {
            XCTFail("Encryption should not fail: \(error)")
        }
    }
    
    func testGenerateRandomKey() {
        // Given
        let length1 = 16
        let length2 = 32
        
        // When
        let key1 = encryptionService.generateRandomKey(length: length1)
        let key2 = encryptionService.generateRandomKey(length: length2)
        let key3 = encryptionService.generateRandomKey(length: length2)
        
        // Then
        XCTAssertEqual(key1.count, length1)
        XCTAssertEqual(key2.count, length2)
        XCTAssertNotEqual(key2, key3, "Two generated keys should be different")
    }
    
    func testHashPassword() throws {
        // Given
        let password = "password123"
        let salt1 = "salt1"
        let salt2 = "salt2"
        
        // When
        let hash1 = try encryptionService.hashPassword(password, salt: salt1)
        let hash2 = try encryptionService.hashPassword(password, salt: salt2)
        let hash1Repeat = try encryptionService.hashPassword(password, salt: salt1)
        
        // Then
        XCTAssertNotEqual(hash1, hash2, "Hashes with different salts should be different")
        XCTAssertEqual(hash1, hash1Repeat, "Hashes with same password and salt should be identical")
    }
    
    func testHashPasswordWithInvalidData() {
        // Given
        let invalidPassword = String(bytes: [0xD8, 0x00] as [UInt8], encoding: .utf8) // Invalid UTF-8 sequence
        let salt = "salt"
        
        // When & Then
        XCTAssertThrowsError(try encryptionService.hashPassword(invalidPassword ?? "", salt: salt)) { error in
            XCTAssertTrue(error is SecurityError)
            if let securityError = error as? SecurityError {
                XCTAssertEqual(securityError.errorDescription, SecurityError.dataConversionFailed.errorDescription)
            }
        }
    }
} 