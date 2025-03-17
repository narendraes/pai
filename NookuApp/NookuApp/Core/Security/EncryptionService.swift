import Foundation
import CryptoSwift

/// Service for encrypting and decrypting data
class EncryptionService: EncryptionServiceProtocol {
    /// Shared instance for singleton access
    static let shared = EncryptionService()
    
    /// Key size in bytes (256 bits)
    private let keySize = 32
    
    /// IV size in bytes (128 bits)
    private let ivSize = 16
    
    /// Key identifier in the Keychain
    private let keyIdentifier = "encryption_key"
    
    /// Private initializer for singleton pattern
    internal init() {
        // Ensure encryption key exists
        if !hasEncryptionKey() {
            _ = generateEncryptionKey()
        }
    }
    
    /// Check if an encryption key exists
    /// - Returns: True if a key exists, false otherwise
    func hasEncryptionKey() -> Bool {
        return KeychainService.shared.exists(for: keyIdentifier)
    }
    
    /// Generate a new encryption key
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func generateEncryptionKey() -> Bool {
        // Generate random key
        var keyData = Data(count: keySize)
        let result = keyData.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, keySize, pointer.baseAddress!)
        }
        
        guard result == errSecSuccess else {
            return false
        }
        
        // Save key to Keychain
        return KeychainService.shared.save(data: keyData, for: keyIdentifier)
    }
    
    /// Generate a random key
    /// - Returns: A random key as Data
    func generateKey() -> Data {
        var keyData = Data(count: keySize)
        _ = keyData.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, keySize, pointer.baseAddress!)
        }
        return keyData
    }
    
    /// Generate a random key string of specified length
    /// - Parameter length: Length of the key in bytes
    /// - Returns: A random key as a hexadecimal string
    func generateRandomKey(length: Int) -> String {
        var keyData = Data(count: length)
        _ = keyData.withUnsafeMutableBytes { pointer in
            SecRandomCopyBytes(kSecRandomDefault, length, pointer.baseAddress!)
        }
        return keyData.map { String(format: "%02hhx", $0) }.joined()
    }
    
    /// Encrypt data using AES-GCM
    /// - Parameters:
    ///   - data: The data to encrypt
    ///   - key: The encryption key
    /// - Returns: The encrypted data, or nil if encryption fails
    func encrypt(data: Data, with key: Data) -> Data? {
        do {
            // Generate random IV
            var iv = Data(count: ivSize)
            let result = iv.withUnsafeMutableBytes { pointer in
                SecRandomCopyBytes(kSecRandomDefault, ivSize, pointer.baseAddress!)
            }
            
            guard result == errSecSuccess else {
                return nil
            }
            
            // Create AES-GCM cipher
            let gcm = GCM(iv: iv.bytes, mode: .combined)
            let aes = try AES(key: key.bytes, blockMode: gcm, padding: .pkcs7)
            
            // Encrypt data
            let ciphertext = try aes.encrypt(data.bytes)
            
            // Return IV + ciphertext
            return Data(iv.bytes + ciphertext)
        } catch {
            return nil
        }
    }
    
    /// Decrypt data using AES-GCM
    /// - Parameters:
    ///   - data: The encrypted data (IV + ciphertext)
    ///   - key: The decryption key
    /// - Returns: The decrypted data, or nil if decryption fails
    func decrypt(data: Data, with key: Data) -> Data? {
        guard data.count > ivSize else {
            return nil
        }
        
        do {
            // Extract IV and ciphertext
            let iv = data.prefix(ivSize)
            let ciphertext = data.suffix(from: ivSize)
            
            // Create AES-GCM cipher
            let gcm = GCM(iv: iv.bytes, mode: .combined)
            let aes = try AES(key: key.bytes, blockMode: gcm, padding: .pkcs7)
            
            // Decrypt data
            let decryptedBytes = try aes.decrypt(ciphertext.bytes)
            return Data(decryptedBytes)
        } catch {
            return nil
        }
    }
    
    /// Encrypt data using the stored encryption key
    /// - Parameter data: The data to encrypt
    /// - Returns: The encrypted data, or nil if encryption fails
    func encrypt(_ data: Data) -> Data? {
        guard let key = retrieveEncryptionKey() else {
            return nil
        }
        
        return encrypt(data: data, with: key)
    }
    
    /// Encrypt a string using AES-GCM
    /// - Parameter string: The string to encrypt
    /// - Returns: The encrypted data as a base64 string, or nil if encryption fails
    func encrypt(_ string: String) -> String? {
        guard let data = string.data(using: .utf8),
              let encryptedData = encrypt(data) else {
            return nil
        }
        
        return encryptedData.base64EncodedString()
    }
    
    /// Decrypt data using the stored encryption key
    /// - Parameter encryptedData: The encrypted data (IV + ciphertext)
    /// - Returns: The decrypted data, or nil if decryption fails
    func decrypt(_ encryptedData: Data) -> Data? {
        guard let key = retrieveEncryptionKey() else {
            return nil
        }
        
        return decrypt(data: encryptedData, with: key)
    }
    
    /// Decrypt a base64 string using AES-GCM
    /// - Parameter base64String: The encrypted data as a base64 string
    /// - Returns: The decrypted string, or nil if decryption fails
    func decrypt(_ base64String: String) -> String? {
        guard let encryptedData = Data(base64Encoded: base64String),
              let decryptedData = decrypt(encryptedData) else {
            return nil
        }
        
        return String(data: decryptedData, encoding: .utf8)
    }
    
    /// Retrieve the encryption key from the Keychain
    /// - Returns: The encryption key, or nil if not found
    private func retrieveEncryptionKey() -> Data? {
        return KeychainService.shared.retrieveData(for: keyIdentifier)
    }
} 