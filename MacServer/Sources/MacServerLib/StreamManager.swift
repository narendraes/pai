import Foundation
import AVFoundation
import Logging
import CoreImage
import AppKit
import Vapor

/// Manages video streaming from the Mac camera
public class StreamManager {
    // MARK: - Properties
    
    /// Shared singleton instance
    public static let shared = StreamManager()
    
    /// Logger for streaming operations
    private let logger = Logger(label: "com.nooku.macserver.stream")
    
    /// Active stream sessions
    private var activeSessions: [UUID: StreamSession] = [:]
    
    /// Queue for synchronizing access to sessions
    private let sessionQueue = DispatchQueue(label: "com.nooku.macserver.stream.sessions", attributes: .concurrent)
    
    // MARK: - Initialization
    
    private init() {
        logger.info("StreamManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Start a new streaming session
    /// - Parameters:
    ///   - quality: The quality level for the stream
    ///   - frameRate: Target frame rate for the stream
    /// - Returns: Session ID for the new stream or nil if failed
    public func startStream(quality: StreamQuality, frameRate: Int) -> UUID? {
        logger.info("Starting new stream with quality: \(quality), frameRate: \(frameRate)")
        
        // Ensure camera is running
        if !CameraManager.shared.isRunning {
            if !CameraManager.shared.startSession() {
                logger.error("Failed to start camera for streaming")
                return nil
            }
        }
        
        // Create new session
        let sessionId = UUID()
        let session = StreamSession(
            id: sessionId,
            quality: quality,
            targetFrameRate: frameRate
        )
        
        // Subscribe to camera frames
        let subscriptionId = CameraManager.shared.subscribeToFrames { [weak session] pixelBuffer in
            guard let session = session else { return }
            session.processFrame(pixelBuffer)
        }
        
        session.cameraSubscriptionId = subscriptionId
        
        // Store session
        sessionQueue.async(flags: .barrier) { [weak self] in
            self?.activeSessions[sessionId] = session
        }
        
        logger.info("Stream started with ID: \(sessionId)")
        return sessionId
    }
    
    /// Stop an active streaming session
    /// - Parameter sessionId: ID of the session to stop
    public func stopStream(sessionId: UUID) {
        logger.info("Stopping stream with ID: \(sessionId)")
        
        sessionQueue.async(flags: .barrier) { [weak self] in
            guard let self = self, let session = self.activeSessions[sessionId] else {
                self?.logger.warning("Attempted to stop non-existent stream: \(sessionId)")
                return
            }
            
            // Unsubscribe from camera frames
            if let subscriptionId = session.cameraSubscriptionId {
                CameraManager.shared.unsubscribeFromFrames(id: subscriptionId)
            }
            
            // Remove session
            self.activeSessions.removeValue(forKey: sessionId)
            self.logger.info("Stream stopped: \(sessionId)")
            
            // If no more active sessions, stop the camera
            if self.activeSessions.isEmpty {
                CameraManager.shared.stopSession()
                self.logger.info("No active streams, camera stopped")
            }
        }
    }
    
    /// Get the next frame from a stream
    /// - Parameter sessionId: ID of the streaming session
    /// - Returns: JPEG data of the frame or nil if not available
    public func getNextFrame(sessionId: UUID) -> Data? {
        var session: StreamSession?
        
        sessionQueue.sync {
            session = activeSessions[sessionId]
        }
        
        guard let session = session else {
            logger.warning("Attempted to get frame from non-existent stream: \(sessionId)")
            return nil
        }
        
        return session.getNextFrameData()
    }
    
    /// Get information about all active streams
    /// - Returns: Array of stream information
    public func getActiveStreams() -> [StreamInfo] {
        var streams: [StreamInfo] = []
        
        sessionQueue.sync {
            streams = activeSessions.values.map { session in
                StreamInfo(
                    id: session.id,
                    quality: session.quality,
                    frameRate: session.targetFrameRate,
                    startTime: session.startTime,
                    framesProcessed: session.framesProcessed
                )
            }
        }
        
        return streams
    }
}

// MARK: - Stream Session

/// Represents an individual streaming session
class StreamSession {
    // MARK: - Properties
    
    /// Unique identifier for the session
    let id: UUID
    
    /// Quality level for the stream
    let quality: StreamQuality
    
    /// Target frame rate
    let targetFrameRate: Int
    
    /// Time when the session started
    let startTime: Date
    
    /// ID for camera frame subscription
    var cameraSubscriptionId: UUID?
    
    /// Count of frames processed
    private(set) var framesProcessed: Int = 0
    
    /// Latest processed frame data
    private var latestFrameData: Data?
    
    /// Queue for synchronizing access to frame data
    private let frameQueue = DispatchQueue(label: "com.nooku.macserver.stream.frame")
    
    /// Timer for frame rate control
    private var frameTimer: DispatchSourceTimer?
    
    /// Time of last frame processing
    private var lastFrameTime = Date()
    
    // MARK: - Initialization
    
    init(id: UUID, quality: StreamQuality, targetFrameRate: Int) {
        self.id = id
        self.quality = quality
        self.targetFrameRate = targetFrameRate
        self.startTime = Date()
        
        setupFrameTimer()
    }
    
    // MARK: - Public Methods
    
    /// Process a new frame from the camera
    /// - Parameter pixelBuffer: The raw pixel buffer from the camera
    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        // Check if we should process this frame based on target frame rate
        let now = Date()
        let timeSinceLastFrame = now.timeIntervalSince(lastFrameTime)
        let targetInterval = 1.0 / Double(targetFrameRate)
        
        if timeSinceLastFrame < targetInterval {
            return
        }
        
        lastFrameTime = now
        
        // Convert frame to JPEG with appropriate quality
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return
        }
        
        // Resize image based on quality setting
        let originalWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let originalHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let scaleFactor = quality.scaleFactor
        
        let targetSize = NSSize(
            width: originalWidth * scaleFactor,
            height: originalHeight * scaleFactor
        )
        
        let image = NSImage(cgImage: cgImage, size: targetSize)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData) else {
            return
        }
        
        // Convert to JPEG with quality based on stream quality
        guard let jpegData = bitmapImage.representation(
            using: .jpeg,
            properties: [.compressionFactor: quality.compressionFactor]
        ) else {
            return
        }
        
        // Store the processed frame
        frameQueue.async(flags: .barrier) { [weak self] in
            self?.latestFrameData = jpegData
            self?.framesProcessed += 1
        }
    }
    
    /// Get the latest processed frame data
    /// - Returns: JPEG data of the frame or nil if not available
    func getNextFrameData() -> Data? {
        var frameData: Data?
        
        frameQueue.sync {
            frameData = latestFrameData
        }
        
        return frameData
    }
    
    // MARK: - Private Methods
    
    private func setupFrameTimer() {
        frameTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
        frameTimer?.schedule(deadline: .now(), repeating: .milliseconds(1000 / targetFrameRate))
        frameTimer?.setEventHandler {
            // This timer ensures we maintain a consistent frame rate
            // The actual frame processing is done in processFrame
        }
        frameTimer?.resume()
    }
}

// MARK: - Stream Quality

/// Quality levels for video streaming
public enum StreamQuality: String, Codable, Sendable, Content {
    case low
    case medium
    case high
    
    /// Scale factor for resizing frames
    var scaleFactor: CGFloat {
        switch self {
        case .low:
            return 0.25
        case .medium:
            return 0.5
        case .high:
            return 1.0
        }
    }
    
    /// Compression factor for JPEG encoding
    var compressionFactor: NSNumber {
        switch self {
        case .low:
            return 0.5
        case .medium:
            return 0.7
        case .high:
            return 0.9
        }
    }
}

// MARK: - Stream Info

/// Information about an active stream
public struct StreamInfo: Codable, Content {
    public let id: UUID
    public let quality: StreamQuality
    public let frameRate: Int
    public let startTime: Date
    public let framesProcessed: Int
    
    public init(id: UUID, quality: StreamQuality, frameRate: Int, startTime: Date, framesProcessed: Int) {
        self.id = id
        self.quality = quality
        self.frameRate = frameRate
        self.startTime = startTime
        self.framesProcessed = framesProcessed
    }
} 