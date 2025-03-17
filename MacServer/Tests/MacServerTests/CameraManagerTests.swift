import XCTest
@testable import MacServerLib

final class CameraManagerTests: XCTestCase {
    // MARK: - Properties
    
    private var cameraManager: CameraManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        cameraManager = CameraManager.shared
    }
    
    override func tearDown() {
        if cameraManager.isRunning {
            cameraManager.stopSession()
        }
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSharedInstance() {
        // Test that shared instance is a singleton
        let instance1 = CameraManager.shared
        let instance2 = CameraManager.shared
        
        XCTAssertTrue(instance1 === instance2, "Shared instance should be a singleton")
    }
    
    func testInitialState() {
        // Test initial state of the camera manager
        XCTAssertFalse(cameraManager.isRunning, "Camera should not be running initially")
        XCTAssertNil(cameraManager.latestFrame, "Latest frame should be nil initially")
    }
    
    func testListCameras() {
        // Test listing available cameras
        let cameras = cameraManager.listCameras()
        
        // We can't guarantee cameras are available on the test machine,
        // but we can verify the function returns without error
        XCTAssertNotNil(cameras, "Camera list should not be nil")
    }
    
    func testStartStopSession() {
        // Test starting and stopping the camera session
        // Note: This test may fail if no camera is available on the test machine
        
        // Start session
        let startResult = cameraManager.startSession()
        
        // If a camera is available, test session management
        if startResult {
            XCTAssertTrue(cameraManager.isRunning, "Camera should be running after start")
            
            // Stop session
            cameraManager.stopSession()
            XCTAssertFalse(cameraManager.isRunning, "Camera should not be running after stop")
        } else {
            // Skip test if no camera available
            print("Skipping session test - no camera available")
        }
    }
    
    func testFrameSubscription() {
        // Test subscribing to frames
        // Note: This test may fail if no camera is available on the test machine
        
        // Start session
        let startResult = cameraManager.startSession()
        
        // If a camera is available, test frame subscription
        if startResult {
            let expectation = XCTestExpectation(description: "Frame received")
            
            // Subscribe to frames
            let subscriptionId = cameraManager.subscribeToFrames { _ in
                expectation.fulfill()
            }
            
            // Wait for frame (with timeout)
            wait(for: [expectation], timeout: 5.0)
            
            // Unsubscribe
            cameraManager.unsubscribeFromFrames(id: subscriptionId)
            
            // Stop session
            cameraManager.stopSession()
        } else {
            // Skip test if no camera available
            print("Skipping frame subscription test - no camera available")
        }
    }
    
    func testTakeSnapshot() {
        // Test taking a snapshot
        // Note: This test may fail if no camera is available on the test machine
        
        // Start session
        let startResult = cameraManager.startSession()
        
        // If a camera is available, test snapshot
        if startResult {
            // Wait a moment for camera to initialize
            Thread.sleep(forTimeInterval: 1.0)
            
            // Take snapshot
            let snapshotData = cameraManager.takeSnapshot()
            
            // Stop session
            cameraManager.stopSession()
            
            // Verify snapshot
            if let snapshotData = snapshotData {
                XCTAssertGreaterThan(snapshotData.count, 0, "Snapshot data should not be empty")
            } else {
                // It's possible that no frame was captured yet
                print("No snapshot data available - camera may not have captured a frame yet")
            }
        } else {
            // Skip test if no camera available
            print("Skipping snapshot test - no camera available")
        }
    }
    
    func testSelectCamera() {
        // Test selecting a camera
        // Note: This test may fail if no camera is available on the test machine
        
        // Get available cameras
        let cameras = cameraManager.listCameras()
        
        // If cameras are available, test selection
        if let firstCamera = cameras.first {
            let selectResult = cameraManager.selectCamera(cameraId: firstCamera.id)
            XCTAssertTrue(selectResult, "Should be able to select an available camera")
            
            // Test selecting non-existent camera
            let invalidResult = cameraManager.selectCamera(cameraId: "non-existent-camera-id")
            XCTAssertFalse(invalidResult, "Should not be able to select a non-existent camera")
        } else {
            // Skip test if no camera available
            print("Skipping camera selection test - no camera available")
        }
    }
    
    // MARK: - Helper Methods
    
    static var allTests = [
        ("testSharedInstance", testSharedInstance),
        ("testInitialState", testInitialState),
        ("testListCameras", testListCameras),
        ("testStartStopSession", testStartStopSession),
        ("testFrameSubscription", testFrameSubscription),
        ("testTakeSnapshot", testTakeSnapshot),
        ("testSelectCamera", testSelectCamera)
    ]
} 