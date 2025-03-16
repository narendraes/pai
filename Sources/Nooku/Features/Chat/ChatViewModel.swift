import Foundation
import Combine

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let model: String?
    
    init(content: String, isFromUser: Bool, model: String? = nil) {
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.model = model
    }
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var selectedModel = "llama2-7b"
    @Published var availableModels: [String] = []
    
    private let ollamaService: OllamaServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(ollamaService: OllamaServiceProtocol? = nil) {
        self.ollamaService = ollamaService ?? DependencyContainer.shared.ollamaService
    }
    
    func sendMessage(content: String) {
        // Add user message
        let userMessage = ChatMessage(content: content, isFromUser: true)
        messages.append(userMessage)
        
        // Set loading state
        isLoading = true
        
        // Generate response
        ollamaService.generateCompletion(prompt: content, model: selectedModel, temperature: 0.7)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    
                    if case .failure(let error) = completion {
                        // Handle error
                        self?.messages.append(
                            ChatMessage(
                                content: "Error: \(error.localizedDescription)",
                                isFromUser: false,
                                model: self?.selectedModel
                            )
                        )
                    }
                },
                receiveValue: { [weak self] response in
                    // Add AI response
                    self?.messages.append(
                        ChatMessage(
                            content: response,
                            isFromUser: false,
                            model: self?.selectedModel
                        )
                    )
                    self?.isLoading = false
                }
            )
            .store(in: &cancellables)
    }
    
    func loadModels() {
        ollamaService.listModels()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] response in
                    self?.availableModels = response.map { $0.name }
                    
                    // Set default model if available
                    if let firstModel = response.first?.name, 
                       !(self?.availableModels.contains(self?.selectedModel ?? "") ?? false) {
                        self?.selectedModel = firstModel
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    func clearMessages() {
        messages.removeAll()
    }
} 