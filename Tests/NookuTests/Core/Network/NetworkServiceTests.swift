import XCTest
import Combine
@testable import Nooku

final class NetworkServiceTests: XCTestCase {
    var cancellables: Set<AnyCancellable> = []
    
    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }
    
    func testEndpointCreation() {
        // Given
        let path = "/api/test"
        let method = HTTPMethod.post
        let headers = ["Content-Type": "application/json"]
        let queryItems = [URLQueryItem(name: "param", value: "value")]
        let body = "test".data(using: .utf8)
        
        // When
        let endpoint = Endpoint(
            path: path,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: body
        )
        
        // Then
        XCTAssertEqual(endpoint.path, path)
        XCTAssertEqual(endpoint.method, method)
        XCTAssertEqual(endpoint.headers, headers)
        XCTAssertEqual(endpoint.queryItems, queryItems)
        XCTAssertEqual(endpoint.body, body)
    }
    
    func testNetworkErrorLocalization() {
        // Given
        let testError = NSError(domain: "test", code: 0, userInfo: [NSLocalizedDescriptionKey: "Test error"])
        
        // When & Then
        XCTAssertEqual(NetworkError.invalidURL.errorDescription, "Invalid URL")
        XCTAssertEqual(NetworkError.requestFailed(testError).errorDescription, "Request failed: Test error")
        XCTAssertEqual(NetworkError.invalidResponse.errorDescription, "Invalid server response")
        XCTAssertEqual(NetworkError.decodingFailed(testError).errorDescription, "Failed to decode response: Test error")
        XCTAssertEqual(NetworkError.unauthorized.errorDescription, "Unauthorized access")
        XCTAssertEqual(NetworkError.serverError(404).errorDescription, "Server error with code: 404")
        XCTAssertEqual(NetworkError.connectionLost.errorDescription, "Connection lost")
        XCTAssertEqual(NetworkError.sshConnectionFailed("test").errorDescription, "SSH connection failed: test")
        XCTAssertEqual(NetworkError.timeout.errorDescription, "Request timed out")
        XCTAssertEqual(NetworkError.unknown(testError).errorDescription, "Unknown error: Test error")
    }
    
    func testMockNetworkService() {
        // Given
        let mockService = MockNetworkService()
        let expectation = XCTestExpectation(description: "Network request")
        
        // Mock response
        struct TestResponse: Codable, Equatable {
            let message: String
        }
        
        let expectedResponse = TestResponse(message: "Success")
        mockService.mockResponse = expectedResponse
        
        // When
        let endpoint = Endpoint(path: "/test")
        mockService.request(endpoint: endpoint, responseType: TestResponse.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Request failed with error: \(error)")
                    }
                },
                receiveValue: { response in
                    // Then
                    XCTAssertEqual(response, expectedResponse)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testMockNetworkServiceError() {
        // Given
        let mockService = MockNetworkService()
        let expectation = XCTestExpectation(description: "Network error")
        
        // Mock error
        let expectedError = NetworkError.serverError(500)
        mockService.mockError = expectedError
        
        // When
        let endpoint = Endpoint(path: "/test")
        mockService.request(endpoint: endpoint, responseType: String.self)
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

// MARK: - Mock Network Service
class MockNetworkService: NetworkService {
    var mockResponse: Any?
    var mockError: NetworkError?
    
    func request<T: Decodable>(endpoint: Endpoint, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
    }
    
    func upload<T: Decodable>(endpoint: Endpoint, data: Data, responseType: T.Type) -> AnyPublisher<T, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? T {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
    }
    
    func download(endpoint: Endpoint) -> AnyPublisher<Data, NetworkError> {
        if let error = mockError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        if let response = mockResponse as? Data {
            return Just(response)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        
        return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
    }
} 