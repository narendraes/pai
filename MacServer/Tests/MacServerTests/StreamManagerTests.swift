import XCTest
@testable import MacServerLib

final class StreamManagerTests: XCTestCase {
    // MARK: - Properties
    
    private var streamManager: StreamManager!
    
    // MARK: - Setup & Teardown
    
    override func setUp() {
        super.setUp()
        streamManager = StreamManager.shared
        
        // Ensure any previous streams are stopped
        for stream in streamManager.getActiveStreams() {
            streamManager.stopStream(sessionId: stream.id)
        }
    }
    
    override func tearDown() {
        // Clean up any active streams
        for stream in streamManager.getActiveStreams() {
            streamManager.stopStream(sessionId: stream.id)
        }
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testSharedInstance() {
        // Test that shared instance is a singleton
        let instance1 = StreamManager.shared
        let instance2 = StreamManager.shared
        
        XCTAssertTrue(instance1 === instance2, "Shared instance should be a singleton")
    }
    
    func testInitialState() {
        // Test initial state of the stream manager
        let activeStreams = streamManager.getActiveStreams()
        XCTAssertEqual(activeStreams.count, 0, "Should have no active streams initially")
    }
    
    func testStartStopStream() {
        // Test starting and stopping a stream
        // Note: This test may fail if no camera is available on the test machine
        
        // Start a stream
        let streamId = streamManager.startStream(quality: .medium, frameRate: 15)
        
        // If a camera is available, test stream management
        if let streamId = streamId {
            // Verify stream is active
            let activeStreams = streamManager.getActiveStreams()
            XCTAssertEqual(activeStreams.count, 1, "Should have one active stream")
            XCTAssertEqual(activeStreams.first?.id, streamId, "Active stream ID should match")
            XCTAssertEqual(activeStreams.first?.quality, .medium, "Stream quality should match")
            XCTAssertEqual(activeStreams.first?.frameRate, 15, "Stream frame rate should match")
            
            // Stop stream
            streamManager.stopStream(sessionId: streamId)
            
            // Verify stream is stopped
            let updatedStreams = streamManager.getActiveStreams()
            XCTAssertEqual(updatedStreams.count, 0, "Should have no active streams after stopping")
        } else {
            // Skip test if no camera available
            print("Skipping stream test - no camera available")
        }
    }
    
    func testMultipleStreams() {
        // Test managing multiple streams
        // Note: This test may fail if no camera is available on the test machine
        
        // Start first stream
        let streamId1 = streamManager.startStream(quality: .low, frameRate: 10)
        
        // If a camera is available, test multiple streams
        if let streamId1 = streamId1 {
            // Start second stream
            let streamId2 = streamManager.startStream(quality: .high, frameRate: 30)
            XCTAssertNotNil(streamId2, "Should be able to start a second stream")
            
            if let streamId2 = streamId2 {
                // Verify both streams are active
                let activeStreams = streamManager.getActiveStreams()
                XCTAssertEqual(activeStreams.count, 2, "Should have two active streams")
                
                // Verify stream properties
                let stream1 = activeStreams.first(where: { $0.id == streamId1 })
                let stream2 = activeStreams.first(where: { $0.id == streamId2 })
                
                XCTAssertNotNil(stream1, "First stream should be active")
                XCTAssertNotNil(stream2, "Second stream should be active")
                
                XCTAssertEqual(stream1?.quality, .low, "First stream quality should match")
                XCTAssertEqual(stream1?.frameRate, 10, "First stream frame rate should match")
                
                XCTAssertEqual(stream2?.quality, .high, "Second stream quality should match")
                XCTAssertEqual(stream2?.frameRate, 30, "Second stream frame rate should match")
                
                // Stop first stream
                streamManager.stopStream(sessionId: streamId1)
                
                // Verify only second stream is active
                let updatedStreams = streamManager.getActiveStreams()
                XCTAssertEqual(updatedStreams.count, 1, "Should have one active stream after stopping first")
                XCTAssertEqual(updatedStreams.first?.id, streamId2, "Remaining stream ID should match second stream")
                
                // Stop second stream
                streamManager.stopStream(sessionId: streamId2)
                
                // Verify no streams are active
                let finalStreams = streamManager.getActiveStreams()
                XCTAssertEqual(finalStreams.count, 0, "Should have no active streams after stopping both")
            }
        } else {
            // Skip test if no camera available
            print("Skipping multiple streams test - no camera available")
        }
    }
    
    func testGetNextFrame() {
        // Test getting frames from a stream
        // Note: This test may fail if no camera is available on the test machine
        
        // Start a stream
        let streamId = streamManager.startStream(quality: .medium, frameRate: 15)
        
        // If a camera is available, test frame retrieval
        if let streamId = streamId {
            // Wait a moment for camera to initialize and capture frames
            Thread.sleep(forTimeInterval: 2.0)
            
            // Get a frame
            let frameData = streamManager.getNextFrame(sessionId: streamId)
            
            // Stop stream
            streamManager.stopStream(sessionId: streamId)
            
            // Verify frame data
            if let frameData = frameData {
                XCTAssertGreaterThan(frameData.count, 0, "Frame data should not be empty")
            } else {
                // It's possible that no frame was captured yet
                print("No frame data available - camera may not have captured a frame yet")
            }
            
            // Test getting frame from non-existent stream
            let invalidFrameData = streamManager.getNextFrame(sessionId: UUID())
            XCTAssertNil(invalidFrameData, "Should not get frame data from non-existent stream")
        } else {
            // Skip test if no camera available
            print("Skipping frame test - no camera available")
        }
    }
    
    func testStreamQuality() {
        // Test stream quality settings
        
        // Test low quality
        XCTAssertEqual(StreamQuality.low.scaleFactor, 0.25, "Low quality scale factor should be 0.25")
        XCTAssertEqual(StreamQuality.low.compressionFactor as? Double, 0.5, "Low quality compression factor should be 0.5")
        
        // Test medium quality
        XCTAssertEqual(StreamQuality.medium.scaleFactor, 0.5, "Medium quality scale factor should be 0.5")
        XCTAssertEqual(StreamQuality.medium.compressionFactor as? Double, 0.7, "Medium quality compression factor should be 0.7")
        
        // Test high quality
        XCTAssertEqual(StreamQuality.high.scaleFactor, 1.0, "High quality scale factor should be 1.0")
        XCTAssertEqual(StreamQuality.high.compressionFactor as? Double, 0.9, "High quality compression factor should be 0.9")
    }
    
    // MARK: - Helper Methods
    
    static var allTests = [
        ("testSharedInstance", testSharedInstance),
        ("testInitialState", testInitialState),
        ("testStartStopStream", testStartStopStream),
        ("testMultipleStreams", testMultipleStreams),
        ("testGetNextFrame", testGetNextFrame),
        ("testStreamQuality", testStreamQuality)
    ]
} 