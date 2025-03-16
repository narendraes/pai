import Foundation

// Define SecurityError enum for testing
enum SecurityError: Error, LocalizedError {
    case encryptionFailed(Error)
    case decryptionFailed(Error)
    case dataConversionFailed
    case invalidKey
    
    var errorDescription: String? {
        switch self {
        case .encryptionFailed(let error):
            return "Encryption failed: \(error.localizedDescription)"
        case .decryptionFailed(let error):
            return "Decryption failed: \(error.localizedDescription)"
        case .dataConversionFailed:
            return "Failed to convert data"
        case .invalidKey:
            return "Invalid encryption key"
        }
    }
}

// Mock CryptoSwift functionality for testing
struct AES {
    static func randomIV(_ size: Int) -> [UInt8] {
        return Array(repeating: 0, count: size)
    }
    
    let key: [UInt8]
    let blockMode: BlockMode
    
    init(key: [UInt8], blockMode: BlockMode) {
        self.key = key
        self.blockMode = blockMode
    }
    
    func encrypt(_ bytes: [UInt8]) throws -> [UInt8] {
        // Simple mock encryption - just append the key to the data
        return bytes + key
    }
    
    func decrypt(_ bytes: [UInt8]) throws -> [UInt8] {
        // Simple mock decryption - just remove the key from the end
        return Array(bytes.prefix(bytes.count - key.count))
    }
}

struct CBC: BlockMode {
    let iv: [UInt8]
    
    init(iv: [UInt8]) {
        self.iv = iv
    }
}

protocol BlockMode {}

struct SHA2 {
    enum Variant {
        case sha256
    }
    
    let variant: Variant
    
    init(variant: Variant) {
        self.variant = variant
    }
    
    func calculate(for bytes: [UInt8]) throws -> [UInt8] {
        // Simple mock hash - just return the first 32 bytes or pad if needed
        if bytes.count >= 32 {
            return Array(bytes.prefix(32))
        } else {
            return bytes + Array(repeating: 0, count: 32 - bytes.count)
        }
    }
}

extension Array where Element == UInt8 {
    func toHexString() -> String {
        return self.map { String(format: "%02x", $0) }.joined()
    }
}

// Safer Data extensions
extension Data {
    // Convert Data to [UInt8]
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}

// Helper function to create Data from bytes
func createData(from bytes: [UInt8]) -> Data {
    return Data(bytes)
}

// Protocol definition
protocol EncryptionServiceProtocol {
    func encrypt(_ data: Data, with key: String) throws -> Data
    func decrypt(_ data: Data, with key: String) throws -> Data
    func generateRandomKey(length: Int) -> String
    func hashPassword(_ password: String, salt: String) throws -> String
}

// EncryptionService implementation (simplified for testing)
class EncryptionService: EncryptionServiceProtocol {
    private let ivSize = 16 // AES block size
    
    func encrypt(_ data: Data, with key: String) throws -> Data {
        // Check for empty key
        if key.isEmpty {
            throw SecurityError.invalidKey
        }
        
        guard let keyData = key.data(using: .utf8) else {
            throw SecurityError.invalidKey
        }
        
        // Generate random IV
        let iv = AES.randomIV(ivSize)
        
        do {
            // Create AES instance
            let aes = AES(key: keyData.bytes, blockMode: CBC(iv: iv))
            
            // Encrypt data
            let encryptedBytes = try aes.encrypt(data.bytes)
            
            // Combine IV and encrypted data
            var encryptedData = createData(from: iv)
            encryptedData.append(createData(from: encryptedBytes))
            
            return encryptedData
        } catch {
            throw SecurityError.encryptionFailed(error)
        }
    }
    
    func decrypt(_ data: Data, with key: String) throws -> Data {
        // Check for empty key
        if key.isEmpty {
            throw SecurityError.invalidKey
        }
        
        guard let keyData = key.data(using: .utf8) else {
            throw SecurityError.invalidKey
        }
        
        // Ensure data is large enough to contain IV and encrypted content
        guard data.count > ivSize else {
            throw SecurityError.decryptionFailed(NSError(domain: "EncryptionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data too short"]))
        }
        
        // Extract IV and encrypted data
        let iv = data.prefix(ivSize).bytes
        let encryptedBytes = data.suffix(from: ivSize).bytes
        
        do {
            // Create AES instance
            let aes = AES(key: keyData.bytes, blockMode: CBC(iv: iv))
            
            // Decrypt data
            let decryptedBytes = try aes.decrypt(encryptedBytes)
            
            return createData(from: decryptedBytes)
        } catch {
            throw SecurityError.decryptionFailed(error)
        }
    }
    
    func generateRandomKey(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,./<>?"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
    
    func hashPassword(_ password: String, salt: String) throws -> String {
        guard let passwordData = password.data(using: .utf8),
              let saltData = salt.data(using: .utf8) else {
            throw SecurityError.dataConversionFailed
        }
        
        do {
            // Combine password and salt
            var combinedData = passwordData
            combinedData.append(saltData)
            
            // Hash using SHA-256
            let digest = SHA2(variant: .sha256)
            let hash = try digest.calculate(for: combinedData.bytes)
            
            return hash.toHexString()
        } catch {
            throw SecurityError.encryptionFailed(error)
        }
    }
}

// Test function
func testEncryptionService() {
    print("Testing EncryptionService...")
    
    let service = EncryptionService()
    var passedTests = 0
    let totalTests = 4
    
    // Test 1: Encrypt and decrypt
    do {
        let originalString = "Hello, world!"
        let key = "testkey12345678"
        
        guard let originalData = originalString.data(using: .utf8) else {
            print("❌ Test 1 (Encrypt/Decrypt): Failed - Could not convert string to data")
            return
        }
        
        let encryptedData = try service.encrypt(originalData, with: key)
        let decryptedData = try service.decrypt(encryptedData, with: key)
        
        if let decryptedString = String(data: decryptedData, encoding: .utf8),
           decryptedString == originalString {
            print("✅ Test 1 (Encrypt/Decrypt): Passed")
            passedTests += 1
        } else {
            print("❌ Test 1 (Encrypt/Decrypt): Failed - Decrypted data doesn't match original")
        }
    } catch {
        print("❌ Test 1 (Encrypt/Decrypt): Failed with error: \(error)")
    }
    
    // Test 2: Invalid key
    do {
        let data = Data([1, 2, 3, 4])
        let emptyKey = ""
        
        do {
            _ = try service.encrypt(data, with: emptyKey)
            print("❌ Test 2 (Invalid Key): Failed - Should have thrown an error")
        } catch SecurityError.invalidKey {
            print("✅ Test 2 (Invalid Key): Passed")
            passedTests += 1
        } catch {
            print("❌ Test 2 (Invalid Key): Failed - Wrong error type: \(error)")
        }
    }
    
    // Test 3: Generate random key
    let key1 = service.generateRandomKey(length: 16)
    let key2 = service.generateRandomKey(length: 16)
    
    if key1.count == 16 && key2.count == 16 && key1 != key2 {
        print("✅ Test 3 (Generate Random Key): Passed")
        passedTests += 1
    } else {
        print("❌ Test 3 (Generate Random Key): Failed")
        print("   Key1: \(key1)")
        print("   Key2: \(key2)")
    }
    
    // Test 4: Hash password
    do {
        let password = "password123"
        let salt = "salt123"
        
        let hash1 = try service.hashPassword(password, salt: salt)
        let hash2 = try service.hashPassword(password, salt: salt)
        
        if !hash1.isEmpty && hash1 == hash2 {
            print("✅ Test 4 (Hash Password): Passed")
            passedTests += 1
        } else {
            print("❌ Test 4 (Hash Password): Failed")
            print("   Hash1: \(hash1)")
            print("   Hash2: \(hash2)")
        }
    } catch {
        print("❌ Test 4 (Hash Password): Failed with error: \(error)")
    }
    
    // Summary
    print("\nTest Results: \(passedTests)/\(totalTests) tests passed")
    if passedTests == totalTests {
        print("All tests passed! 🎉")
    } else {
        print("Some tests failed. 😢")
    }
}

// Run the tests
testEncryptionService() 