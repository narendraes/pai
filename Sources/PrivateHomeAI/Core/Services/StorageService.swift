import Foundation

public class StorageService {
    public static let shared = StorageService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    public func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    public func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    public func delete(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    public func clear() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
    }
} 