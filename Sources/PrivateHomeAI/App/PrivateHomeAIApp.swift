import SwiftUI
import Combine

// Import required services
import Security
import LocalAuthentication

// Service definitions
class SSHService: ObservableObject {
    static let shared = SSHService()
    @Published var connectionStatus: ConnectionStatus = .disconnected
    private init() {}
}

class BiometricAuthService {
    static let shared = BiometricAuthService()
    private init() {}
    
    func authenticate(reason: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            completion(.failure(error ?? NSError(domain: "BiometricAuthService", code: -1)))
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "BiometricAuthService", code: -2)))
                }
            }
        }
    }
}

class StorageService {
    static let shared = StorageService()
    private let defaults = UserDefaults.standard
    private init() {}
    
    func save<T: Encodable>(_ value: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// ConnectionStatus enum definition
enum ConnectionStatus: CustomStringConvertible {
    case connected
    case disconnected
    case connecting
    case error(String)
    
    var description: String {
        switch self {
        case .connected: return "Connected"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .error(let message): return "Error: \(message)"
        }
    }
}

@main
struct NookuApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        print("DEBUG: NookuApp initializing...")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    print("DEBUG: NookuApp rendering ContentView...")
                    print("DEBUG: ContentView onAppear triggered")
                    // Check for jailbreak
                    if JailbreakDetectionService.shared.isJailbroken() {
                        print("DEBUG: Jailbreak detected")
                        appState.showJailbreakAlert = true
                    }
                }
                .alert("Security Warning", isPresented: $appState.showJailbreakAlert) {
                    Button("Exit", role: .destructive) {
                        exit(0)
                    }
                } message: {
                    Text("This device appears to be jailbroken. For security reasons, this app cannot run on jailbroken devices.")
                }
        }
    }
}

/// Tab selection options
enum TabSelection {
    case chat
    case cameras
    case analysis
    case settings
} 