import Foundation
import AVFoundation
import Logging

/// Manages camera access and streaming for the Mac server
public class CameraManager {
    // MARK: - Properties
    
    /// Shared singleton instance
    public static let shared = CameraManager()
    
    /// Logger for camera operations
    private let logger = Logger(label: "com.nooku.macserver.camera")
    
    /// Capture session for the camera
    private let captureSession = AVCaptureSession()
    
    /// Video data output for processing frames
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    /// Queue for processing video frames
    private let videoDataOutputQueue = DispatchQueue(label: "com.nooku.macserver.camera.videoqueue", qos: .userInteractive)
    
    /// Current camera device
    private var currentDevice: AVCaptureDevice?
    
    /// Flag indicating if the camera is running
    private(set) public var isRunning = false
    
    /// Latest captured frame
    private(set) public var latestFrame: CVPixelBuffer?
    
    /// Subscribers for frame updates
    private var frameSubscribers: [UUID: (CVPixelBuffer) -> Void] = [:]
    
    // MARK: - Initialization
    
    private init() {
        logger.info("CameraManager initialized")
    }
    
    // MARK: - Public Methods
    
    /// Start the camera session
    /// - Returns: True if successfully started, false otherwise
    public func startSession() -> Bool {
        logger.info("Starting camera session")
        
        guard !isRunning else {
            logger.warning("Camera session already running")
            return true
        }
        
        do {
            try setupCaptureSession()
            captureSession.startRunning()
            isRunning = captureSession.isRunning
            logger.info("Camera session started: \(isRunning)")
            return isRunning
        } catch {
            logger.error("Failed to start camera session: \(error)")
            return false
        }
    }
    
    /// Stop the camera session
    public func stopSession() {
        logger.info("Stopping camera session")
        
        guard isRunning else {
            logger.warning("Camera session not running")
            return
        }
        
        captureSession.stopRunning()
        isRunning = false
        logger.info("Camera session stopped")
    }
    
    /// Subscribe to frame updates
    /// - Parameter handler: Closure to be called with each new frame
    /// - Returns: Subscription ID to use for unsubscribing
    public func subscribeToFrames(handler: @escaping (CVPixelBuffer) -> Void) -> UUID {
        let id = UUID()
        frameSubscribers[id] = handler
        logger.debug("Added frame subscriber: \(id)")
        return id
    }
    
    /// Unsubscribe from frame updates
    /// - Parameter id: Subscription ID returned from subscribeToFrames
    public func unsubscribeFromFrames(id: UUID) {
        frameSubscribers.removeValue(forKey: id)
        logger.debug("Removed frame subscriber: \(id)")
    }
    
    /// Take a snapshot from the current camera
    /// - Returns: Image data in JPEG format, or nil if not available
    public func takeSnapshot() -> Data? {
        guard let frame = latestFrame else {
            logger.warning("No frame available for snapshot")
            return nil
        }
        
        let ciImage = CIImage(cvPixelBuffer: frame)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            logger.error("Failed to create CGImage from frame")
            return nil
        }
        
        let image = NSImage(cgImage: cgImage, size: NSSize(width: CGFloat(CVPixelBufferGetWidth(frame)), height: CGFloat(CVPixelBufferGetHeight(frame))))
        
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmapImage.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            logger.error("Failed to convert image to JPEG")
            return nil
        }
        
        logger.info("Snapshot taken: \(jpegData.count) bytes")
        return jpegData
    }
    
    /// List available camera devices
    /// - Returns: Array of camera device information
    public func listCameras() -> [CameraInfo] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        
        return discoverySession.devices.map { device in
            CameraInfo(
                id: device.uniqueID,
                name: device.localizedName,
                position: positionString(for: device.position)
            )
        }
    }
    
    /// Select a specific camera by ID
    /// - Parameter cameraId: Unique ID of the camera to select
    /// - Returns: True if successfully selected, false otherwise
    public func selectCamera(cameraId: String) -> Bool {
        logger.info("Selecting camera: \(cameraId)")
        
        let wasRunning = isRunning
        if wasRunning {
            stopSession()
        }
        
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        
        guard let device = discoverySession.devices.first(where: { $0.uniqueID == cameraId }) else {
            logger.error("Camera not found: \(cameraId)")
            return false
        }
        
        currentDevice = device
        
        if wasRunning {
            return startSession()
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func setupCaptureSession() throws {
        captureSession.beginConfiguration()
        
        // Clear any existing inputs and outputs
        for input in captureSession.inputs {
            captureSession.removeInput(input)
        }
        
        for output in captureSession.outputs {
            captureSession.removeOutput(output)
        }
        
        // Set up the capture device
        let device = currentDevice ?? defaultCaptureDevice()
        
        guard let device = device else {
            throw CameraError.noDeviceAvailable
        }
        
        logger.info("Using camera device: \(device.localizedName)")
        
        // Create device input
        let deviceInput = try AVCaptureDeviceInput(device: device)
        
        guard captureSession.canAddInput(deviceInput) else {
            throw CameraError.cannotAddInput
        }
        
        captureSession.addInput(deviceInput)
        
        // Set up video data output
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        guard captureSession.canAddOutput(videoDataOutput) else {
            throw CameraError.cannotAddOutput
        }
        
        captureSession.addOutput(videoDataOutput)
        
        // Set session preset
        captureSession.sessionPreset = .high
        
        captureSession.commitConfiguration()
        
        logger.info("Capture session setup complete")
    }
    
    private func defaultCaptureDevice() -> AVCaptureDevice? {
        // Try to get the default video device
        if let device = AVCaptureDevice.default(for: .video) {
            return device
        }
        
        // If that fails, try to get any video device
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, .externalUnknown],
            mediaType: .video,
            position: .unspecified
        )
        
        return discoverySession.devices.first
    }
    
    private func positionString(for position: AVCaptureDevice.Position) -> String {
        switch position {
        case .back:
            return "back"
        case .front:
            return "front"
        case .unspecified:
            return "unknown"
        @unknown default:
            return "unknown"
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            logger.warning("Failed to get pixel buffer from sample buffer")
            return
        }
        
        latestFrame = pixelBuffer
        
        // Notify subscribers
        for (_, handler) in frameSubscribers {
            handler(pixelBuffer)
        }
    }
}

// MARK: - Camera Info Struct

public struct CameraInfo: Codable {
    public let id: String
    public let name: String
    public let position: String
    
    public init(id: String, name: String, position: String) {
        self.id = id
        self.name = name
        self.position = position
    }
}

// MARK: - Camera Errors

enum CameraError: Error {
    case noDeviceAvailable
    case cannotAddInput
    case cannotAddOutput
}

extension CameraError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noDeviceAvailable:
            return "No camera device available"
        case .cannotAddInput:
            return "Cannot add input to capture session"
        case .cannotAddOutput:
            return "Cannot add output to capture session"
        }
    }
} 