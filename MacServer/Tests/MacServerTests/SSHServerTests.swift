import XCTest
@testable import MacServerLib

final class SSHServerTests: XCTestCase {
    // MARK: - Properties
    
    private var sshServer: SSHServer!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        sshServer = SSHServer.shared
        
        // Ensure server is stopped before each test
        if sshServer.isRunning {
            sshServer.stop()
        }
    }
    
    override func tearDown() {
        // Clean up after tests
        if sshServer.isRunning {
            sshServer.stop()
        }
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSharedInstance() {
        // Test that shared instance is a singleton
        let instance1 = SSHServer.shared
        let instance2 = SSHServer.shared
        
        XCTAssertTrue(instance1 === instance2, "Shared instance should be a singleton")
    }
    
    func testInitialState() {
        // Test initial state of the SSH server
        XCTAssertFalse(sshServer.isRunning, "SSH server should not be running initially")
        XCTAssertEqual(sshServer.port, 2222, "Default port should be 2222")
        XCTAssertEqual(sshServer.getActiveConnections().count, 0, "Should have no active connections initially")
    }
    
    func testStartStop() {
        // Test starting and stopping the SSH server
        
        // Start server
        let startResult = sshServer.start(port: 2222)
        XCTAssertTrue(startResult, "Server should start successfully")
        XCTAssertTrue(sshServer.isRunning, "Server should be running after start")
        XCTAssertEqual(sshServer.port, 2222, "Port should be set correctly")
        
        // Start again (should be idempotent)
        let startAgainResult = sshServer.start(port: 3333)
        XCTAssertTrue(startAgainResult, "Starting again should succeed")
        XCTAssertEqual(sshServer.port, 2222, "Port should not change when already running")
        
        // Stop server
        sshServer.stop()
        XCTAssertFalse(sshServer.isRunning, "Server should not be running after stop")
        
        // Stop again (should be idempotent)
        sshServer.stop()
        XCTAssertFalse(sshServer.isRunning, "Server should remain stopped")
        
        // Start with different port
        let startNewPortResult = sshServer.start(port: 3333)
        XCTAssertTrue(startNewPortResult, "Server should start with new port")
        XCTAssertEqual(sshServer.port, 3333, "Port should be updated")
    }
    
    func testAuthorizedKeys() {
        // Test managing authorized keys
        
        // Get initial keys
        let initialKeys = sshServer.getAuthorizedKeys()
        
        // Add a key
        let keyData = "test-key-data".data(using: .utf8)!
        let addResult = sshServer.addAuthorizedKey(key: keyData, comment: "Test Key")
        XCTAssertTrue(addResult, "Adding key should succeed")
        
        // Verify key was added
        let keysAfterAdd = sshServer.getAuthorizedKeys()
        XCTAssertEqual(keysAfterAdd.count, initialKeys.count + 1, "Key count should increase by 1")
        
        // Find the added key
        let addedKey = keysAfterAdd.first(where: { $0.comment == "Test Key" })
        XCTAssertNotNil(addedKey, "Added key should be found")
        XCTAssertEqual(addedKey?.keyData, keyData, "Key data should match")
        
        if let addedKey = addedKey {
            // Remove the key
            let removeResult = sshServer.removeAuthorizedKey(id: addedKey.id)
            XCTAssertTrue(removeResult, "Removing key should succeed")
            
            // Verify key was removed
            let keysAfterRemove = sshServer.getAuthorizedKeys()
            XCTAssertEqual(keysAfterRemove.count, initialKeys.count, "Key count should return to initial value")
            XCTAssertNil(keysAfterRemove.first(where: { $0.id == addedKey.id }), "Removed key should not be found")
            
            // Try to remove non-existent key
            let removeNonExistentResult = sshServer.removeAuthorizedKey(id: addedKey.id)
            XCTAssertFalse(removeNonExistentResult, "Removing non-existent key should fail")
        }
    }
    
    func testSimulateConnections() {
        // Test simulating connections (for testing purposes)
        
        // Start server
        sshServer.start()
        
        // Simulate a connection
        let connectionId = sshServer.simulateNewConnection(clientAddress: "192.168.1.100", username: "testuser")
        
        // Verify connection was added
        let connections = sshServer.getActiveConnections()
        XCTAssertEqual(connections.count, 1, "Should have one active connection")
        
        let connection = connections.first
        XCTAssertEqual(connection?.id, connectionId, "Connection ID should match")
        XCTAssertEqual(connection?.clientAddress, "192.168.1.100", "Client address should match")
        XCTAssertEqual(connection?.username, "testuser", "Username should match")
        
        // Stop server (should close all connections)
        sshServer.stop()
        
        // Verify connections were closed
        let connectionsAfterStop = sshServer.getActiveConnections()
        XCTAssertEqual(connectionsAfterStop.count, 0, "Should have no active connections after stop")
    }
    
    // MARK: - Helper Methods
    
    static var allTests = [
        ("testSharedInstance", testSharedInstance),
        ("testInitialState", testInitialState),
        ("testStartStop", testStartStop),
        ("testAuthorizedKeys", testAuthorizedKeys),
        ("testSimulateConnections", testSimulateConnections)
    ]
} 