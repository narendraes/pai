import Foundation
import Security

protocol KeychainServiceProtocol {
    func save(key: String, data: Data) throws
    func load(key: String) throws -> Data?
    func delete(key: String) throws
    func clear() throws
}

class KeychainService: KeychainServiceProtocol {
    private let service: String
    
    init(service: String = Bundle.main.bundleIdentifier ?? "com.privatehomeai") {
        self.service = service
    }
    
    func save(key: String, data: Data) throws {
        // First try to update existing item
        var query = baseQuery(for: key)
        var status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        
        // If item doesn't exist, add it
        if status == errSecItemNotFound {
            query[kSecValueData as String] = data
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw SecurityError.keychainError(status)
        }
    }
    
    func load(key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw SecurityError.keychainError(status)
        }
        
        return result as? Data
    }
    
    func delete(key: String) throws {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityError.keychainError(status)
        }
    }
    
    func clear() throws {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityError.keychainError(status)
        }
    }
    
    private func baseQuery(for key: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: service,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
    }
} 