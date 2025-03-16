import Foundation
import Combine

/// Client for interacting with the Ollama API
class OllamaClient {
    /// Shared instance
    static let shared = OllamaClient()
    
    /// Base URL for the Ollama API
    private let baseURL = "http://localhost:11434/api"
    
    /// Default model to use
    private let defaultModel = "llama3"
    
    /// URL session for network requests
    private let session = URLSession.shared
    
    /// Private initializer for singleton
    private init() {}
    
    /// Generate a response from the LLM
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: Model to use (defaults to llama3)
    ///   - temperature: Temperature for generation (0.0-1.0)
    ///   - completion: Callback with generation result
    func generateResponse(
        messages: [OllamaAPIMessage],
        model: String? = nil,
        temperature: Double = 0.7,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Create request URL
        guard let url = URL(string: "\(baseURL)/chat") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": model ?? defaultModel,
            "messages": messages.map { $0.apiRepresentation },
            "temperature": temperature,
            "stream": false
        ]
        
        // Convert request body to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Simulate API call (for demo purposes)
        simulateAPICall(messages: messages, completion: completion)
    }
    
    /// Stream a response from the LLM
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: Model to use (defaults to llama3)
    ///   - temperature: Temperature for generation (0.0-1.0)
    ///   - onToken: Callback for each token
    ///   - completion: Callback with final generation result
    func streamResponse(
        messages: [OllamaAPIMessage],
        model: String? = nil,
        temperature: Double = 0.7,
        onToken: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        // Create request URL
        guard let url = URL(string: "\(baseURL)/chat") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request body
        let requestBody: [String: Any] = [
            "model": model ?? defaultModel,
            "messages": messages.map { $0.apiRepresentation },
            "temperature": temperature,
            "stream": true
        ]
        
        // Convert request body to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NetworkError.invalidResponse))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Simulate streaming API call (for demo purposes)
        simulateStreamingAPICall(messages: messages, onToken: onToken, completion: completion)
    }
    
    /// List available models
    /// - Parameter completion: Callback with models result
    func listModels(completion: @escaping (Result<[OllamaModel], Error>) -> Void) {
        // Create request URL
        guard let url = URL(string: "\(baseURL)/tags") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Simulate API call (for demo purposes)
        let models = [
            OllamaModel(name: "llama3", size: "8B", modified: Date()),
            OllamaModel(name: "mistral", size: "7B", modified: Date()),
            OllamaModel(name: "phi3", size: "3.8B", modified: Date()),
            OllamaModel(name: "gemma", size: "7B", modified: Date())
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            completion(.success(models))
        }
    }
    
    // MARK: - Private Methods
    
    /// Simulate API call for demo purposes
    private func simulateAPICall(messages: [OllamaAPIMessage], completion: @escaping (Result<String, Error>) -> Void) {
        DispatchQueue.global().async {
            // Simulate network delay
            Thread.sleep(forTimeInterval: 1.0)
            
            // Get the last user message
            let lastUserMessage = messages.last { $0.role == .user }?.content ?? ""
            
            // Generate a response based on the message content
            let response = self.generateSimulatedResponse(for: lastUserMessage)
            
            DispatchQueue.main.async {
                completion(.success(response))
            }
        }
    }
    
    /// Simulate streaming API call for demo purposes
    private func simulateStreamingAPICall(
        messages: [OllamaAPIMessage],
        onToken: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        DispatchQueue.global().async {
            // Get the last user message
            let lastUserMessage = messages.last { $0.role == .user }?.content ?? ""
            
            // Generate a response based on the message content
            let response = self.generateSimulatedResponse(for: lastUserMessage)
            
            // Split response into tokens
            let tokens = response.split(separator: " ").map(String.init)
            var fullResponse = ""
            
            // Stream tokens with delay
            for token in tokens {
                Thread.sleep(forTimeInterval: 0.1)
                fullResponse += token + " "
                
                DispatchQueue.main.async {
                    onToken(token + " ")
                }
            }
            
            DispatchQueue.main.async {
                completion(.success(fullResponse))
            }
        }
    }
    
    /// Generate a simulated response based on the user message
    private func generateSimulatedResponse(for message: String) -> String {
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("hello") || lowercasedMessage.contains("hi") {
            return "Hello! I'm your Private Home AI assistant. How can I help you today?"
        } else if lowercasedMessage.contains("camera") {
            return "I can help you with your home cameras. You can view camera feeds, check their status, or set up motion detection alerts. Would you like me to show you the available cameras?"
        } else if lowercasedMessage.contains("security") {
            return "Your home security is important. All cameras are currently online and no unusual activity has been detected in the last 24 hours. Would you like me to run a security check?"
        } else if lowercasedMessage.contains("weather") {
            return "Based on the outdoor camera data, it appears to be sunny with an estimated temperature of around 72°F (22°C). Would you like me to show you the weather forecast?"
        } else if lowercasedMessage.contains("help") {
            return "I can help you with various tasks:\n- Monitor your cameras\n- Analyze security footage\n- Control smart home devices\n- Answer questions about your home\n\nWhat would you like assistance with?"
        } else if lowercasedMessage.contains("analyze") || lowercasedMessage.contains("detection") {
            return "I can analyze camera footage for objects, people, or scenes. This processing happens locally on your device for privacy. Would you like me to analyze recent footage from a specific camera?"
        } else if lowercasedMessage.contains("privacy") {
            return "Your privacy is my priority. All processing happens locally on your device, and no data is sent to external servers unless you explicitly request it. Your home data stays in your home."
        } else {
            return "I understand you're asking about \"\(message)\". As your home assistant, I can help with camera monitoring, security analysis, and answering questions about your home environment. How can I assist you with this specifically?"
        }
    }
}

/// Ollama model information
struct OllamaModel: Identifiable {
    /// Model name
    let name: String
    
    /// Model size
    let size: String
    
    /// Last modified date
    let modified: Date
    
    /// Unique identifier
    var id: String { name }
} 