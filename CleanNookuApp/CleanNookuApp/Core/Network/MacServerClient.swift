import Foundation
import Combine
import UIKit

/// Client for interacting with the Mac Server API
class MacServerClient: ObservableObject {
    // MARK: - Properties
    
    /// Singleton instance
    static let shared = MacServerClient()
    
    /// Published properties for SwiftUI
    @Published var isConnected = false
    @Published var availableCameras: [MacCamera] = []
    @Published var currentImage: UIImage?
    @Published var error: Error?
    @Published var debugMessage: String = ""
    @Published var alertItem: AlertItem?
    
    /// Server configuration
    private var serverURL = URL(string: "http://192.168.5.110:8080")!
    private var apiKey = "test-api-key"
    
    /// URL session for API requests
    private let session: URLSession
    
    /// Cancellables for managing subscriptions
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        DispatchQueue.main.async {
            self.debugMessage = "Initializing with URL: \(self.serverURL.absoluteString)"
        }
        
        // Configure URL session with more permissive settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    
    /// Update the server configuration
    /// - Parameters:
    ///   - url: The new server URL
    ///   - apiKey: The new API key
    func updateServerConfig(url: URL, apiKey: String) {
        self.serverURL = url
        self.apiKey = apiKey
    }
    
    /// Check if the server is reachable
    /// - Returns: A publisher that emits a boolean indicating if the server is reachable
    func checkConnection() -> AnyPublisher<Bool, Error> {
        let url = serverURL.appendingPathComponent("health")
        
        DispatchQueue.main.async {
            self.debugMessage += "\nChecking connection to: \(url.absoluteString)"
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse else {
                    DispatchQueue.main.async {
                        self.debugMessage += "\nInvalid response type"
                    }
                    throw URLError(.badServerResponse)
                }
                
                DispatchQueue.main.async {
                    self.debugMessage += "\nReceived HTTP \(httpResponse.statusCode)"
                }
                
                guard httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.debugMessage += "\nInvalid status code: \(httpResponse.statusCode)"
                    }
                    throw URLError(.badServerResponse)
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? "No data"
                DispatchQueue.main.async {
                    self.debugMessage += "\nServer response: \(responseString)"
                }
                return true
            }
            .handleEvents(receiveOutput: { [weak self] isConnected in
                DispatchQueue.main.async {
                    self?.isConnected = isConnected
                    self?.debugMessage += "\nConnection successful: \(isConnected)"
                }
            }, receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        self?.debugMessage += "\nConnection error: \(error.localizedDescription)"
                    }
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// List available cameras on the Mac
    /// - Returns: A publisher that emits an array of camera information
    func listCameras() -> AnyPublisher<[MacCamera], Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras")
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CameraListResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .handleEvents(receiveOutput: { [weak self] cameras in
                DispatchQueue.main.async {
                    self?.availableCameras = cameras
                    self?.debugMessage += "\nReceived \(cameras.count) cameras"
                }
            })
            .eraseToAnyPublisher()
    }
    
    /// Select a specific camera
    /// - Parameter cameraId: The ID of the camera to select
    /// - Returns: A publisher that emits whether the selection was successful
    func selectCamera(cameraId: String) -> AnyPublisher<Bool, Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras/select")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["cameraId": cameraId]
        request.httpBody = try? JSONEncoder().encode(body)
        
        DispatchQueue.main.async {
            self.debugMessage += "\nSelecting camera: \(cameraId)"
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    DispatchQueue.main.async {
                        self.debugMessage += "\nFailed to select camera: \(cameraId)"
                    }
                    throw URLError(.badServerResponse)
                }
                
                DispatchQueue.main.async {
                    self.debugMessage += "\nCamera selected: \(cameraId)"
                }
                
                return true
            }
            .eraseToAnyPublisher()
    }
    
    /// Take a snapshot from the current camera
    /// - Returns: A publisher that emits the captured image
    func takeSnapshot() -> AnyPublisher<UIImage, Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras/snapshot")
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        DispatchQueue.main.async {
            self.debugMessage += "\nTaking snapshot..."
        }
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> UIImage in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let image = UIImage(data: data) else {
                    DispatchQueue.main.async {
                        self.debugMessage += "\nFailed to process snapshot"
                    }
                    throw URLError(.badServerResponse)
                }
                
                DispatchQueue.main.async {
                    self.debugMessage += "\nSnapshot received: \(data.count) bytes"
                }
                
                return image
            }
            .handleEvents(receiveOutput: { [weak self] image in
                DispatchQueue.main.async {
                    self?.currentImage = image
                }
            })
            .eraseToAnyPublisher()
    }
    
    func updateServerURL(_ newURL: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.serverURL = newURL
            self?.debugMessage += "\nUpdated server URL to: \(newURL.absoluteString)"
        }
    }
    
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.alertItem = AlertItem(title: title, message: message)
        }
    }
}

// MARK: - Models

/// Represents a camera on the Mac server
struct MacCamera: Identifiable, Codable {
    let id: String
    let name: String
    let position: String
}

/// Response for camera list API
struct CameraListResponse: Codable {
    let success: Bool
    let data: [MacCamera]
}

/// Empty API response
struct EmptyResponse: Codable {
    let success: Bool
}

// MARK: - Errors

enum MacServerError: Error, LocalizedError {
    case connectionFailed
    case invalidResponse
    case cameraSelectionFailed
    case snapshotFailed
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed:
            return "Failed to connect to Mac server"
        case .invalidResponse:
            return "Received invalid response from server"
        case .cameraSelectionFailed:
            return "Failed to select camera"
        case .snapshotFailed:
            return "Failed to take snapshot"
        }
    }
} 