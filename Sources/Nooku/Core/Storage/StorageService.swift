import Foundation
import Combine

/// Service for storing and retrieving data locally
class StorageService {
    /// Shared instance for singleton access
    static let shared = StorageService()
    
    /// UserDefaults instance
    private let defaults = UserDefaults.standard
    
    /// Encryption service for secure storage
    private let encryptionService = EncryptionService.shared
    
    /// Private initializer for singleton pattern
    private init() {}
    
    /// Save a value to UserDefaults
    /// - Parameters:
    ///   - value: The value to save
    ///   - key: The key to save the value under
    ///   - encrypted: Whether to encrypt the value
    func save<T: Encodable>(_ value: T, forKey key: String, encrypted: Bool = false) {
        do {
            let data = try JSONEncoder().encode(value)
            
            if encrypted {
                guard let encryptedData = encryptionService.encrypt(data),
                      let base64String = encryptedData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .alphanumerics) else {
                    return
                }
                defaults.set(base64String, forKey: key)
            } else {
                defaults.set(data, forKey: key)
            }
        } catch {
            print("Error saving value for key \(key): \(error)")
        }
    }
    
    /// Retrieve a value from UserDefaults
    /// - Parameters:
    ///   - key: The key to retrieve the value for
    ///   - encrypted: Whether the value is encrypted
    /// - Returns: The retrieved value, or nil if not found
    func retrieve<T: Decodable>(_ type: T.Type, forKey key: String, encrypted: Bool = false) -> T? {
        if encrypted {
            guard let base64String = defaults.string(forKey: key),
                  let percentDecoded = base64String.removingPercentEncoding,
                  let encryptedData = Data(base64Encoded: percentDecoded),
                  let decryptedData = encryptionService.decrypt(encryptedData) else {
                return nil
            }
            
            do {
                return try JSONDecoder().decode(type, from: decryptedData)
            } catch {
                print("Error decoding value for key \(key): \(error)")
                return nil
            }
        } else {
            guard let data = defaults.data(forKey: key) else {
                return nil
            }
            
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                print("Error decoding value for key \(key): \(error)")
                return nil
            }
        }
    }
    
    /// Remove a value from UserDefaults
    /// - Parameter key: The key to remove
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// Check if a value exists in UserDefaults
    /// - Parameter key: The key to check
    /// - Returns: True if the value exists, false otherwise
    func exists(forKey key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    /// Save a simple value to UserDefaults
    /// - Parameters:
    ///   - value: The value to save
    ///   - key: The key to save the value under
    func saveSimple<T>(_ value: T, forKey key: String) where T: Any {
        defaults.set(value, forKey: key)
    }
    
    /// Retrieve a simple value from UserDefaults
    /// - Parameters:
    ///   - type: The type of the value
    ///   - key: The key to retrieve the value for
    /// - Returns: The retrieved value, or nil if not found
    func retrieveSimple<T>(_ type: T.Type, forKey key: String) -> T? {
        return defaults.object(forKey: key) as? T
    }
    
    /// Save data to a file
    /// - Parameters:
    ///   - data: The data to save
    ///   - fileName: The name of the file
    ///   - encrypted: Whether to encrypt the data
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func saveToFile(_ data: Data, fileName: String, encrypted: Bool = false) -> Bool {
        guard let fileURL = getDocumentsURL(fileName: fileName) else {
            return false
        }
        
        do {
            if encrypted {
                guard let encryptedData = encryptionService.encrypt(data) else {
                    return false
                }
                try encryptedData.write(to: fileURL)
            } else {
                try data.write(to: fileURL)
            }
            return true
        } catch {
            print("Error saving file \(fileName): \(error)")
            return false
        }
    }
    
    /// Load data from a file
    /// - Parameters:
    ///   - fileName: The name of the file
    ///   - encrypted: Whether the data is encrypted
    /// - Returns: The loaded data, or nil if not found
    func loadFromFile(fileName: String, encrypted: Bool = false) -> Data? {
        guard let fileURL = getDocumentsURL(fileName: fileName),
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            
            if encrypted {
                return encryptionService.decrypt(data)
            } else {
                return data
            }
        } catch {
            print("Error loading file \(fileName): \(error)")
            return nil
        }
    }
    
    /// Delete a file
    /// - Parameter fileName: The name of the file
    /// - Returns: True if successful, false otherwise
    @discardableResult
    func deleteFile(fileName: String) -> Bool {
        guard let fileURL = getDocumentsURL(fileName: fileName),
              FileManager.default.fileExists(atPath: fileURL.path) else {
            return false
        }
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            return true
        } catch {
            print("Error deleting file \(fileName): \(error)")
            return false
        }
    }
    
    /// Get the URL for a file in the Documents directory
    /// - Parameter fileName: The name of the file
    /// - Returns: The URL, or nil if not found
    private func getDocumentsURL(fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentsDirectory.appendingPathComponent(fileName)
    }
} 