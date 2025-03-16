import Foundation
import Combine

/// Service for managing chat interactions with the LLM
class ChatService: ObservableObject {
    /// Shared instance
    static let shared = ChatService()
    
    /// Chat history
    @Published var chatHistory: [ChatMessageViewModel] = []
    
    /// Flag indicating if a response is being generated
    @Published var isGeneratingResponse = false
    
    /// System prompt that defines the assistant's capabilities
    private let systemPrompt = """
    You are a helpful AI assistant for a private home automation and security system.
    You can help with:
    1. Monitoring security cameras and providing status updates
    2. Analyzing camera footage for objects, people, and scenes
    3. Answering questions about the home environment
    4. Providing suggestions for home security and automation
    
    All processing happens locally on the user's device for privacy.
    Be helpful, concise, and security-focused in your responses.
    """
    
    /// Ollama client for LLM interactions
    private let ollamaClient = OllamaClient.shared
    
    /// Storage service for persisting chat history
    private let storageService = StorageService.shared
    
    /// Private initializer for singleton
    private init() {
        loadChatHistory()
    }
    
    /// Send a message to the LLM
    /// - Parameters:
    ///   - message: User message
    ///   - completion: Callback with result
    func sendMessage(_ message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Create user message
        let userMessage = ChatMessageViewModel(id: UUID().uuidString, content: message, role: .user, timestamp: Date())
        
        // Add to chat history
        chatHistory.append(userMessage)
        
        // Save chat history
        saveChatHistory()
        
        // Set generating flag
        isGeneratingResponse = true
        
        // Convert chat history to API format
        var apiMessages: [OllamaAPIMessage] = []
        
        // Add system message
        let systemMessage = OllamaAPIMessage(role: .system, content: systemPrompt)
        apiMessages.append(systemMessage)
        
        // Add last 10 messages from chat history (or fewer if not available)
        let recentMessages = chatHistory.suffix(10)
        for message in recentMessages {
            let apiRole: OllamaAPIMessageRole
            switch message.role {
            case .user:
                apiRole = .user
            case .assistant:
                apiRole = .assistant
            }
            let apiMessage = OllamaAPIMessage(role: apiRole, content: message.content)
            apiMessages.append(apiMessage)
        }
        
        // Generate response
        ollamaClient.generateResponse(messages: apiMessages) { [weak self] (result: Result<String, Error>) in
            guard let self = self else { return }
            
            // Reset generating flag
            self.isGeneratingResponse = false
            
            switch result {
            case .success(let response):
                // Create assistant message
                let assistantMessage = ChatMessageViewModel(id: UUID().uuidString, content: response, role: .assistant, timestamp: Date())
                
                // Add to chat history
                self.chatHistory.append(assistantMessage)
                
                // Save chat history
                self.saveChatHistory()
                
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Clear chat history
    func clearChatHistory() {
        chatHistory = []
        saveChatHistory()
    }
    
    // MARK: - Private Methods
    
    /// Save chat history to storage
    private func saveChatHistory() {
        storageService.save(chatHistory, forKey: "chatHistory", encrypted: true)
    }
    
    /// Load chat history from storage
    private func loadChatHistory() {
        if let history: [ChatMessageViewModel] = storageService.retrieve([ChatMessageViewModel].self, forKey: "chatHistory", encrypted: true) {
            chatHistory = history
        }
    }
}

/// View model for chat messages
struct ChatMessageViewModel: Identifiable, Codable {
    /// Message ID
    let id: String
    
    /// Message content
    let content: String
    
    /// Message role
    let role: ViewMessageRole
    
    /// Message timestamp
    let timestamp: Date
}

/// Message role for view model
enum ViewMessageRole: String, Codable {
    case user
    case assistant
} 