import Foundation
import CryptoSwift

protocol EncryptionServiceProtocol {
    func encrypt(_ data: Data, with key: String) throws -> Data
    func decrypt(_ data: Data, with key: String) throws -> Data
    func generateRandomKey(length: Int) -> String
    func hashPassword(_ password: String, salt: String) throws -> String
}

class EncryptionService: EncryptionServiceProtocol {
    private let ivSize = 16 // AES block size
    
    func encrypt(_ data: Data, with key: String) throws -> Data {
        guard let keyData = key.data(using: .utf8) else {
            throw SecurityError.invalidKey
        }
        
        // Generate random IV
        let iv = AES.randomIV(ivSize)
        
        do {
            // Create AES instance
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv))
            
            // Encrypt data
            let encryptedBytes = try aes.encrypt(data.bytes)
            
            // Combine IV and encrypted data
            var encryptedData = Data(iv)
            encryptedData.append(Data(encryptedBytes))
            
            return encryptedData
        } catch {
            throw SecurityError.encryptionFailed(error)
        }
    }
    
    func decrypt(_ data: Data, with key: String) throws -> Data {
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
            let aes = try AES(key: keyData.bytes, blockMode: CBC(iv: iv))
            
            // Decrypt data
            let decryptedBytes = try aes.decrypt(encryptedBytes)
            
            return Data(decryptedBytes)
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