import Foundation

// Define SecurityError enum for testing
enum SecurityError: Error, LocalizedError {
    case keychainError(OSStatus)
    
    var errorDescription: String? {
        switch self {
        case .keychainError(let status):
            return "Keychain error with status: \(status)"
        }
    }
}

// Mock Security framework for testing
typealias CFDictionary = [String: Any]
typealias OSStatus = Int32

let errSecSuccess: OSStatus = 0
let errSecItemNotFound: OSStatus = -25300

let kSecClass = "class"
let kSecClassGenericPassword = "genp"
let kSecAttrAccount = "acct"
let kSecAttrService = "svce"
let kSecAttrAccessible = "accessible"
let kSecAttrAccessibleAfterFirstUnlock = "af1"
let kSecValueData = "v_Data"
let kSecReturnData = "r_Data"
let kSecMatchLimit = "m_Limit"
let kSecMatchLimitOne = "m_LimitOne"

// Mock keychain storage
class MockKeychain {
    static var shared = MockKeychain()
    var storage: [String: Data] = [:]
    
    func reset() {
        storage = [:]
    }
    
    func makeKey(from query: CFDictionary) -> String? {
        guard let service = query[kSecAttrService] as? String,
              let account = query[kSecAttrAccount] as? String else {
            return nil
        }
        return "\(service)_\(account)"
    }
}

// Mock Security framework functions
func SecItemUpdate(_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus {
    guard let key = MockKeychain.shared.makeKey(from: query) else {
        return errSecItemNotFound
    }
    
    if MockKeychain.shared.storage[key] != nil {
        if let data = attributesToUpdate[kSecValueData] as? Data {
            MockKeychain.shared.storage[key] = data
            return errSecSuccess
        }
        return errSecItemNotFound
    }
    
    return errSecItemNotFound
}

func SecItemAdd(_ attributes: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
    guard let key = MockKeychain.shared.makeKey(from: attributes),
          let data = attributes[kSecValueData] as? Data else {
        return errSecItemNotFound
    }
    
    MockKeychain.shared.storage[key] = data
    return errSecSuccess
}

func SecItemCopyMatching(_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus {
    guard let key = MockKeychain.shared.makeKey(from: query) else {
        return errSecItemNotFound
    }
    
    if let data = MockKeychain.shared.storage[key] {
        result?.pointee = data as CFTypeRef
        return errSecSuccess
    }
    
    return errSecItemNotFound
}

func SecItemDelete(_ query: CFDictionary) -> OSStatus {
    if let key = MockKeychain.shared.makeKey(from: query) {
        if MockKeychain.shared.storage[key] != nil {
            MockKeychain.shared.storage.removeValue(forKey: key)
            return errSecSuccess
        }
        return errSecItemNotFound
    } else if let service = query[kSecAttrService] as? String {
        // Clear all items for this service
        let keysToRemove = MockKeychain.shared.storage.keys.filter { $0.starts(with: "\(service)_") }
        for key in keysToRemove {
            MockKeychain.shared.storage.removeValue(forKey: key)
        }
        return errSecSuccess
    }
    
    return errSecItemNotFound
}

// Protocol definition
protocol KeychainServiceProtocol {
    func save(key: String, data: Data) throws
    func load(key: String) throws -> Data?
    func delete(key: String) throws
    func clear() throws
}

// KeychainService implementation
class KeychainService: KeychainServiceProtocol {
    private let service: String
    
    init(service: String = "com.test.privatehomeai") {
        self.service = service
    }
    
    func save(key: String, data: Data) throws {
        // First try to update existing item
        var query = baseQuery(for: key)
        var status = SecItemUpdate(query as CFDictionary, [kSecValueData: data] as CFDictionary)
        
        // If item doesn't exist, add it
        if status == errSecItemNotFound {
            query[kSecValueData] = data
            status = SecItemAdd(query as CFDictionary, nil)
        }
        
        guard status == errSecSuccess else {
            throw SecurityError.keychainError(status)
        }
    }
    
    func load(key: String) throws -> Data? {
        var query = baseQuery(for: key)
        query[kSecReturnData] = true
        query[kSecMatchLimit] = kSecMatchLimitOne
        
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
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecurityError.keychainError(status)
        }
    }
    
    private func baseQuery(for key: String) -> [String: Any] {
        return [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrService: service,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]
    }
}

// Test function
func testKeychainService() {
    print("Testing KeychainService...")
    
    // Reset mock keychain before tests
    MockKeychain.shared.reset()
    
    let service = KeychainService(service: "com.test.privatehomeai")
    var passedTests = 0
    let totalTests = 4
    
    // Test 1: Save and load data
    do {
        let key = "testKey"
        let testString = "Hello, Keychain!"
        let testData = testString.data(using: .utf8)!
        
        try service.save(key: key, data: testData)
        let loadedData = try service.load(key: key)
        
        if let loadedData = loadedData,
           let loadedString = String(data: loadedData, encoding: .utf8),
           loadedString == testString {
            print("✅ Test 1 (Save/Load): Passed")
            passedTests += 1
        } else {
            print("❌ Test 1 (Save/Load): Failed")
            print("   Expected: \(testString)")
            print("   Actual: \(loadedData.flatMap { String(data: $0, encoding: .utf8) } ?? "nil")")
        }
    } catch {
        print("❌ Test 1 (Save/Load): Failed with error: \(error)")
    }
    
    // Test 2: Update existing data
    do {
        let key = "updateKey"
        let initialString = "Initial data"
        let updatedString = "Updated data"
        
        try service.save(key: key, data: initialString.data(using: .utf8)!)
        try service.save(key: key, data: updatedString.data(using: .utf8)!)
        
        let loadedData = try service.load(key: key)
        
        if let loadedData = loadedData,
           let loadedString = String(data: loadedData, encoding: .utf8),
           loadedString == updatedString {
            print("✅ Test 2 (Update): Passed")
            passedTests += 1
        } else {
            print("❌ Test 2 (Update): Failed")
            print("   Expected: \(updatedString)")
            print("   Actual: \(loadedData.flatMap { String(data: $0, encoding: .utf8) } ?? "nil")")
        }
    } catch {
        print("❌ Test 2 (Update): Failed with error: \(error)")
    }
    
    // Test 3: Delete data
    do {
        let key = "deleteKey"
        let testString = "Delete me"
        
        try service.save(key: key, data: testString.data(using: .utf8)!)
        try service.delete(key: key)
        
        let loadedData = try service.load(key: key)
        
        if loadedData == nil {
            print("✅ Test 3 (Delete): Passed")
            passedTests += 1
        } else {
            print("❌ Test 3 (Delete): Failed - Data still exists after deletion")
        }
    } catch {
        print("❌ Test 3 (Delete): Failed with error: \(error)")
    }
    
    // Test 4: Clear all data
    do {
        let keys = ["key1", "key2", "key3"]
        
        for key in keys {
            try service.save(key: key, data: "Test data".data(using: .utf8)!)
        }
        
        try service.clear()
        
        var allCleared = true
        for key in keys {
            if let _ = try service.load(key: key) {
                allCleared = false
                break
            }
        }
        
        if allCleared {
            print("✅ Test 4 (Clear): Passed")
            passedTests += 1
        } else {
            print("❌ Test 4 (Clear): Failed - Some data still exists after clearing")
        }
    } catch {
        print("❌ Test 4 (Clear): Failed with error: \(error)")
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
testKeychainService() 