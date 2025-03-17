import Foundation
import Security

/// Service for secure credential storage using the Keychain
class KeychainService: KeychainServiceProtocol {
    /// Shared instance
    static let shared = KeychainService()
    
    /// Service name for keychain items
    private let serviceName = "com.privateai.home"
    
    /// Private initializer for singleton
    internal init() {}
    
    /// Save a string value to the keychain
    /// - Parameters:
    ///   - value: String value to save
    ///   - key: Key to associate with the value
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        return save(data: data, for: key)
    }
    
    /// Save data to the keychain
    /// - Parameters:
    ///   - data: Data to save
    ///   - key: Key to associate with the data
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func save(data: Data, for key: String) -> Bool {
        // Delete existing item if it exists
        delete(key: key)
        
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add item to keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Save data to the keychain with throws
    /// - Parameters:
    ///   - key: Key to associate with the data
    ///   - data: Data to save
    /// - Throws: Error if save fails
    func save(key: String, data: Data) throws {
        // Delete existing item if it exists
        delete(key: key)
        
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Add item to keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw NSError(domain: "com.privateai.home.keychain", code: Int(status), userInfo: [NSLocalizedDescriptionKey: "Failed to save to keychain"])
        }
    }
    
    /// Retrieve a string value from the keychain
    /// - Parameter key: Key associated with the value
    /// - Returns: String value if found, nil otherwise
    func retrieveString(for key: String) -> String? {
        guard let data = retrieveData(for: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Retrieve data from the keychain
    /// - Parameter key: Key associated with the data
    /// - Returns: Data if found, nil otherwise
    func retrieveData(for key: String) -> Data? {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Query keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        // Check result
        if status == errSecSuccess, let data = result as? Data {
            return data
        }
        return nil
    }
    
    /// Delete an item from the keychain
    /// - Parameter key: Key associated with the item
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func delete(key: String) -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        // Delete item from keychain
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    /// Check if an item exists in the keychain
    /// - Parameter key: Key to check
    /// - Returns: True if the item exists, false otherwise
    func exists(for key: String) -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        // Query keychain
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        return status == errSecSuccess
    }
    
    /// Update an existing item in the keychain
    /// - Parameters:
    ///   - value: New string value
    ///   - key: Key associated with the item
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func update(value: String, for key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }
        return update(data: data, for: key)
    }
    
    /// Update an existing item in the keychain
    /// - Parameters:
    ///   - data: New data
    ///   - key: Key associated with the item
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func update(data: Data, for key: String) -> Bool {
        // Create query dictionary
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        // Create update dictionary
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]
        
        // Update item in keychain
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        
        // If item doesn't exist, create it
        if status == errSecItemNotFound {
            return save(data: data, for: key)
        }
        
        return status == errSecSuccess
    }
} 