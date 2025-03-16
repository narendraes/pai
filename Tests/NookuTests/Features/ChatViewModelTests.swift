import XCTest
import Combine
@testable import Nooku

final class ChatViewModelTests: XCTestCase {
    var viewModel: ChatViewModel!
    var mockOllamaService: MockOllamaService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockOllamaService = MockOllamaService()
        viewModel = ChatViewModel(ollamaService: mockOllamaService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockOllamaService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testSendMessage() {
        // Given
        let expectation = XCTestExpectation(description: "Send message")
        let userMessage = "Hello, AI!"
        let aiResponse = "Hello, human! How can I help you today?"
        let model = "llama2-7b"
        
        mockOllamaService.completionToReturn = aiResponse
        mockOllamaService.modelNameToReturn = model
        
        // When
        viewModel.sendMessage(content: userMessage)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.messages.count, 2)
            
            let firstMessage = self.viewModel.messages[0]
            XCTAssertEqual(firstMessage.content, userMessage)
            XCTAssertTrue(firstMessage.isFromUser)
            
            let secondMessage = self.viewModel.messages[1]
            XCTAssertEqual(secondMessage.content, aiResponse)
            XCTAssertFalse(secondMessage.isFromUser)
            XCTAssertEqual(secondMessage.model, model)
            
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testSendMessageError() {
        // Given
        let expectation = XCTestExpectation(description: "Send message error")
        let userMessage = "Hello, AI!"
        
        mockOllamaService.shouldSucceed = false
        mockOllamaService.errorToReturn = NetworkError.connectionLost
        
        // When
        viewModel.sendMessage(content: userMessage)
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.messages.count, 2)
            
            let firstMessage = self.viewModel.messages[0]
            XCTAssertEqual(firstMessage.content, userMessage)
            XCTAssertTrue(firstMessage.isFromUser)
            
            let secondMessage = self.viewModel.messages[1]
            XCTAssertTrue(secondMessage.content.contains("Error"))
            XCTAssertFalse(secondMessage.isFromUser)
            
            XCTAssertFalse(self.viewModel.isLoading)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadModels() {
        // Given
        let expectation = XCTestExpectation(description: "Load models")
        let models = ["llama2-7b", "mistral-7b", "codellama-7b"]
        
        mockOllamaService.modelsToReturn = models.map { OllamaModel(name: $0, size: 0, modified: Date()) }
        
        // When
        viewModel.loadModels()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.availableModels, models)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadModelsWithDefaultSelection() {
        // Given
        let expectation = XCTestExpectation(description: "Load models with default selection")
        let models = ["mistral-7b", "codellama-7b"]
        
        // Set a model that's not in the list
        viewModel.selectedModel = "llama2-7b"
        
        mockOllamaService.modelsToReturn = models.map { OllamaModel(name: $0, size: 0, modified: Date()) }
        
        // When
        viewModel.loadModels()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertEqual(self.viewModel.availableModels, models)
            XCTAssertEqual(self.viewModel.selectedModel, "mistral-7b")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testClearMessages() {
        // Given
        viewModel.messages = [
            ChatMessage(content: "Hello", isFromUser: true),
            ChatMessage(content: "Hi there", isFromUser: false, model: "llama2-7b")
        ]
        
        // When
        viewModel.clearMessages()
        
        // Then
        XCTAssertTrue(viewModel.messages.isEmpty)
    }
    
    func testChatMessageInitialization() {
        // Given
        let content = "Test message"
        let isFromUser = true
        let model = "llama2-7b"
        
        // When
        let message = ChatMessage(content: content, isFromUser: isFromUser, model: model)
        
        // Then
        XCTAssertEqual(message.content, content)
        XCTAssertEqual(message.isFromUser, isFromUser)
        XCTAssertEqual(message.model, model)
        XCTAssertNotNil(message.id)
        XCTAssertNotNil(message.timestamp)
    }
}

// MARK: - Mock Ollama Service
class MockOllamaService: OllamaServiceProtocol {
    var shouldSucceed = true
    var errorToReturn: NetworkError?
    var completionToReturn = ""
    var modelNameToReturn = "llama2-7b"
    var modelsToReturn: [OllamaModel] = []
    
    func generateCompletion(prompt: String, model: String, temperature: Float) -> AnyPublisher<OllamaCompletionResponse, NetworkError> {
        if shouldSucceed {
            let response = OllamaCompletionResponse(
                model: modelNameToReturn,
                response: completionToReturn,
                done: true
            )
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.invalidResponse)
                .eraseToAnyPublisher()
        }
    }
    
    func listModels() -> AnyPublisher<OllamaListModelsResponse, NetworkError> {
        if shouldSucceed {
            let response = OllamaListModelsResponse(models: modelsToReturn)
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.invalidResponse)
                .eraseToAnyPublisher()
        }
    }
    
    func pullModel(model: String) -> AnyPublisher<Bool, NetworkError> {
        if shouldSucceed {
            return Just(true)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: errorToReturn ?? NetworkError.invalidResponse)
                .eraseToAnyPublisher()
        }
    }
} 