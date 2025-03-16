import Foundation

/// Protocol for keychain operations
protocol KeychainServiceProtocol {
    func save(value: String, for key: String) -> Bool
    func retrieveString(for key: String) -> String?
    func delete(key: String) -> Bool
    func save(key: String, data: Data) throws
    func retrieveData(for key: String) -> Data?
}

/// Protocol for encryption operations
protocol EncryptionServiceProtocol {
    func encrypt(data: Data, with key: Data) -> Data?
    func decrypt(data: Data, with key: Data) -> Data?
    func generateKey() -> Data
    func generateRandomKey(length: Int) -> String
    func encrypt(_ data: Data) -> Data?
    func encrypt(_ string: String) -> String?
    func decrypt(_ encryptedData: Data) -> Data?
    func decrypt(_ base64String: String) -> String?
}

/// Protocol for jailbreak detection
public protocol JailbreakDetectionServiceProtocol {
    func isJailbroken() -> Bool
} 