import XCTest
import Combine
@testable import Nooku

final class OllamaServiceTests: XCTestCase {
    var mockNetworkService: MockNetworkService!
    var ollamaService: OllamaService!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        ollamaService = OllamaService(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        mockNetworkService = nil
        ollamaService = nil
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testGenerateCompletion() {
        // Given
        let expectation = XCTestExpectation(description: "Generate completion")
        let prompt = "Hello, world!"
        let model = "llama2-7b"
        let temperature: Float = 0.7
        
        let expectedResponse = OllamaCompletionResponse(
            model: model,
            response: "Hello! How can I assist you today?",
            done: true
        )
        
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        ollamaService.generateCompletion(prompt: prompt, model: model, temperature: temperature)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Request failed with error: \(error)")
                    }
                },
                receiveValue: { response in
                    // Then
                    XCTAssertEqual(response, expectedResponse.response)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testGenerateCompletionError() {
        // Given
        let expectation = XCTestExpectation(description: "Generate completion error")
        let prompt = "Hello, world!"
        let model = "llama2-7b"
        let temperature: Float = 0.7
        
        let expectedError = NetworkError.serverError(500)
        mockNetworkService.mockError = expectedError
        
        // When
        ollamaService.generateCompletion(prompt: prompt, model: model, temperature: temperature)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error.errorDescription, expectedError.errorDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Request should have failed")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testListModels() {
        // Given
        let expectation = XCTestExpectation(description: "List models")
        
        let expectedModels = [
            OllamaModel(name: "llama2-7b", size: 4_000_000_000, modified: Date()),
            OllamaModel(name: "mistral-7b", size: 4_200_000_000, modified: Date())
        ]
        
        let expectedResponse = OllamaListModelsResponse(models: expectedModels)
        mockNetworkService.mockResponse = expectedResponse
        
        // When
        ollamaService.listModels()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Request failed with error: \(error)")
                    }
                },
                receiveValue: { models in
                    // Then
                    XCTAssertEqual(models.count, expectedModels.count)
                    XCTAssertEqual(models[0].name, expectedModels[0].name)
                    XCTAssertEqual(models[1].name, expectedModels[1].name)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPullModel() {
        // Given
        let expectation = XCTestExpectation(description: "Pull model")
        let model = "llama2-7b"
        
        // Mock successful download
        mockNetworkService.mockResponse = Data()
        
        // When
        ollamaService.pullModel(model: model)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Request failed with error: \(error)")
                    }
                },
                receiveValue: { success in
                    // Then
                    XCTAssertTrue(success)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPullModelError() {
        // Given
        let expectation = XCTestExpectation(description: "Pull model error")
        let model = "llama2-7b"
        
        let expectedError = NetworkError.connectionLost
        mockNetworkService.mockError = expectedError
        
        // When
        ollamaService.pullModel(model: model)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        // Then
                        XCTAssertEqual(error.errorDescription, expectedError.errorDescription)
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Request should have failed")
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
} 