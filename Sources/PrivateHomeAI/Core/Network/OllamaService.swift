import Foundation
import Combine

protocol OllamaServiceProtocol {
    func generateCompletion(prompt: String, model: String, temperature: Float) -> AnyPublisher<String, NetworkError>
    func listModels() -> AnyPublisher<[OllamaModel], NetworkError>
    func pullModel(model: String) -> AnyPublisher<Bool, NetworkError>
}

struct OllamaModel: Codable {
    let name: String
    let size: Int64
    let modified: Date
    
    enum CodingKeys: String, CodingKey {
        case name
        case size
        case modified
    }
}

struct OllamaCompletionRequest: Codable {
    let model: String
    let prompt: String
    let temperature: Float
    let stream: Bool
    
    init(model: String, prompt: String, temperature: Float = 0.7, stream: Bool = false) {
        self.model = model
        self.prompt = prompt
        self.temperature = temperature
        self.stream = stream
    }
}

struct OllamaCompletionResponse: Codable {
    let model: String
    let response: String
    let done: Bool
}

struct OllamaListModelsResponse: Codable {
    let models: [OllamaModel]
}

class OllamaService: OllamaServiceProtocol {
    private let networkService: NetworkService
    private let baseURL: URL
    
    init(networkService: NetworkService, baseURL: URL = URL(string: "http://localhost:11434")!) {
        self.networkService = networkService
        self.baseURL = baseURL
    }
    
    func generateCompletion(prompt: String, model: String, temperature: Float) -> AnyPublisher<String, NetworkError> {
        let request = OllamaCompletionRequest(model: model, prompt: prompt, temperature: temperature)
        
        guard let requestData = try? JSONEncoder().encode(request) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let endpoint = Endpoint(
            path: "/api/generate",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestData
        )
        
        return networkService.request(endpoint: endpoint, responseType: OllamaCompletionResponse.self)
            .map { $0.response }
            .eraseToAnyPublisher()
    }
    
    func listModels() -> AnyPublisher<[OllamaModel], NetworkError> {
        let endpoint = Endpoint(
            path: "/api/tags",
            method: .get,
            headers: ["Content-Type": "application/json"]
        )
        
        return networkService.request(endpoint: endpoint, responseType: OllamaListModelsResponse.self)
            .map { $0.models }
            .eraseToAnyPublisher()
    }
    
    func pullModel(model: String) -> AnyPublisher<Bool, NetworkError> {
        struct PullModelRequest: Codable {
            let name: String
        }
        
        let request = PullModelRequest(name: model)
        
        guard let requestData = try? JSONEncoder().encode(request) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        let endpoint = Endpoint(
            path: "/api/pull",
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: requestData
        )
        
        // For pull, we just need to know if it succeeded
        return networkService.download(endpoint: endpoint)
            .map { _ in true }
            .eraseToAnyPublisher()
    }
} 