import XCTest
@testable import MacServerLib

final class APIServerTests: XCTestCase {
    // MARK: - Properties
    
    private var apiServer: APIServer!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        apiServer = APIServer.shared
        
        // Ensure server is stopped before each test
        if apiServer.isRunning {
            apiServer.stop()
        }
    }
    
    override func tearDown() {
        // Clean up after tests
        if apiServer.isRunning {
            apiServer.stop()
        }
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSharedInstance() {
        // Test that shared instance is a singleton
        let instance1 = APIServer.shared
        let instance2 = APIServer.shared
        
        XCTAssertTrue(instance1 === instance2, "Shared instance should be a singleton")
    }
    
    func testInitialState() {
        // Test initial state of the API server
        XCTAssertFalse(apiServer.isRunning, "API server should not be running initially")
        XCTAssertEqual(apiServer.port, 8080, "Default port should be 8080")
    }
    
    func testStartStop() {
        // Test starting and stopping the API server
        
        // Start server
        let startResult = apiServer.start(port: 8080)
        XCTAssertTrue(startResult, "Server should start successfully")
        XCTAssertTrue(apiServer.isRunning, "Server should be running after start")
        XCTAssertEqual(apiServer.port, 8080, "Port should be set correctly")
        
        // Start again (should be idempotent)
        let startAgainResult = apiServer.start(port: 9090)
        XCTAssertTrue(startAgainResult, "Starting again should succeed")
        XCTAssertEqual(apiServer.port, 8080, "Port should not change when already running")
        
        // Stop server
        apiServer.stop()
        XCTAssertFalse(apiServer.isRunning, "Server should not be running after stop")
        
        // Stop again (should be idempotent)
        apiServer.stop()
        XCTAssertFalse(apiServer.isRunning, "Server should remain stopped")
        
        // Start with different port
        let startNewPortResult = apiServer.start(port: 9090)
        XCTAssertTrue(startNewPortResult, "Server should start with new port")
        XCTAssertEqual(apiServer.port, 9090, "Port should be updated")
    }
    
    func testAPIResponse() {
        // Test API response structure
        
        // Success response with data
        let successResponse = APIResponse(
            success: true,
            data: VersionInfo(version: "1.0.0", buildNumber: "1", apiVersion: "v1")
        )
        
        XCTAssertTrue(successResponse.success, "Success flag should be true")
        XCTAssertEqual(successResponse.data.version, "1.0.0", "Version should match")
        XCTAssertEqual(successResponse.data.buildNumber, "1", "Build number should match")
        XCTAssertEqual(successResponse.data.apiVersion, "v1", "API version should match")
        XCTAssertNil(successResponse.error, "Error should be nil for success response")
        
        // Error response
        let errorResponse = APIResponse<EmptyResponse>(
            success: false,
            data: EmptyResponse(),
            error: "Test error"
        )
        
        XCTAssertFalse(errorResponse.success, "Success flag should be false")
        XCTAssertEqual(errorResponse.error, "Test error", "Error message should match")
    }
    
    func testResponseModels() {
        // Test response model structures
        
        // Empty response
        let emptyResponse = EmptyResponse()
        XCTAssertNotNil(emptyResponse, "Empty response should be instantiable")
        
        // Version info
        let versionInfo = VersionInfo(version: "1.0.0", buildNumber: "1", apiVersion: "v1")
        XCTAssertEqual(versionInfo.version, "1.0.0", "Version should match")
        XCTAssertEqual(versionInfo.buildNumber, "1", "Build number should match")
        XCTAssertEqual(versionInfo.apiVersion, "v1", "API version should match")
        
        // Stream response
        let streamId = UUID()
        let streamResponse = StreamResponse(
            streamId: streamId,
            streamUrl: "/api/v1/streams/\(streamId.uuidString)/frame"
        )
        XCTAssertEqual(streamResponse.streamId, streamId, "Stream ID should match")
        XCTAssertEqual(streamResponse.streamUrl, "/api/v1/streams/\(streamId.uuidString)/frame", "Stream URL should match")
        
        // SSH status response
        let sshStatusResponse = SSHStatusResponse(running: true, port: 2222, connections: 3)
        XCTAssertTrue(sshStatusResponse.running, "Running flag should match")
        XCTAssertEqual(sshStatusResponse.port, 2222, "Port should match")
        XCTAssertEqual(sshStatusResponse.connections, 3, "Connection count should match")
        
        // Authorized key response
        let keyId = UUID()
        let createdAt = Date()
        let keyResponse = AuthorizedKeyResponse(id: keyId, comment: "Test Key", createdAt: createdAt)
        XCTAssertEqual(keyResponse.id, keyId, "Key ID should match")
        XCTAssertEqual(keyResponse.comment, "Test Key", "Comment should match")
        XCTAssertEqual(keyResponse.createdAt, createdAt, "Created at should match")
    }
    
    // MARK: - Helper Methods
    
    static var allTests = [
        ("testSharedInstance", testSharedInstance),
        ("testInitialState", testInitialState),
        ("testStartStop", testStartStop),
        ("testAPIResponse", testAPIResponse),
        ("testResponseModels", testResponseModels)
    ]
} 