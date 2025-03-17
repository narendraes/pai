import Foundation
import AVFoundation
import UIKit
import Combine

class CameraManager: NSObject, ObservableObject {
    // Published properties for SwiftUI
    @Published var currentImage: UIImage?
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var error: CameraError?
    @Published var flashMode: AVCaptureDevice.FlashMode = .off
    @Published var isRecording = false
    @Published var lastSavedMediaURL: URL?
    @Published var lastSavedMediaType: MediaType?
    
    // Camera configuration
    private let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private let photoOutput = AVCapturePhotoOutput()
    private let videoOutput = AVCaptureMovieFileOutput()
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // Current camera position
    private var currentPosition: AVCaptureDevice.Position = .back
    
    // Temporary URL for video recording
    private var tempVideoURL: URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("temp_video_\(Date().timeIntervalSince1970).mov")
    }
    
    // App storage directory for media
    private var mediaDirectory: URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let mediaDirectory = documentsDirectory.appendingPathComponent("NookuMedia", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !fileManager.fileExists(atPath: mediaDirectory.path) {
            do {
                try fileManager.createDirectory(at: mediaDirectory, withIntermediateDirectories: true)
                return mediaDirectory
            } catch {
                self.error = .fileSystemError(error)
                return nil
            }
        }
        
        return mediaDirectory
    }
    
    // Photo storage directory
    private var photosDirectory: URL? {
        guard let mediaDir = mediaDirectory else { return nil }
        let photosDir = mediaDir.appendingPathComponent("Photos", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: photosDir.path) {
            do {
                try FileManager.default.createDirectory(at: photosDir, withIntermediateDirectories: true)
                return photosDir
            } catch {
                self.error = .fileSystemError(error)
                return nil
            }
        }
        
        return photosDir
    }
    
    // Video storage directory
    private var videosDirectory: URL? {
        guard let mediaDir = mediaDirectory else { return nil }
        let videosDir = mediaDir.appendingPathComponent("Videos", isDirectory: true)
        
        // Create directory if it doesn't exist
        if !FileManager.default.fileExists(atPath: videosDir.path) {
            do {
                try FileManager.default.createDirectory(at: videosDir, withIntermediateDirectories: true)
                return videosDir
            } catch {
                self.error = .fileSystemError(error)
                return nil
            }
        }
        
        return videosDir
    }
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permission Handling
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.isAuthorized = true
            self.setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isAuthorized = granted
                    if granted {
                        self?.setupSession()
                    }
                }
            }
        case .denied, .restricted:
            self.isAuthorized = false
            self.error = .notAuthorized
        @unknown default:
            self.isAuthorized = false
            self.error = .unknown
        }
    }
    
    // MARK: - Session Setup
    
    private func setupSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            
            // Set session preset
            if self.session.canSetSessionPreset(.high) {
                self.session.sessionPreset = .high
            }
            
            // Setup video input
            self.setupVideoInput()
            
            // Setup photo output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)
                self.photoOutput.isHighResolutionCaptureEnabled = true
                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            // Setup video output
            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }
            
            self.session.commitConfiguration()
            
            DispatchQueue.main.async {
                self.startSession()
            }
        }
    }
    
    private func setupVideoInput(position: AVCaptureDevice.Position? = nil) {
        // Remove existing input if any
        if let currentInput = self.videoDeviceInput {
            self.session.removeInput(currentInput)
            self.videoDeviceInput = nil
        }
        
        // Determine which camera to use
        let position = position ?? self.currentPosition
        self.currentPosition = position
        
        // Get the device
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position) else {
            self.error = .cameraUnavailable
            return
        }
        
        // Create input
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
            } else {
                self.error = .cannotAddInput
            }
        } catch {
            self.error = .createCaptureInput(error)
        }
    }
    
    // MARK: - Session Control
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, !self.session.isRunning else { return }
            self.session.startRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
            }
        }
    }
    
    // MARK: - Camera Controls
    
    func switchCamera() {
        let newPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.session.beginConfiguration()
            self.setupVideoInput(position: newPosition)
            self.session.commitConfiguration()
        }
    }
    
    func setFlashMode(_ mode: AVCaptureDevice.FlashMode) {
        self.flashMode = mode
    }
    
    // MARK: - Capture Methods
    
    func capturePhoto() {
        guard isSessionRunning else { return }
        
        let settings = AVCapturePhotoSettings()
        
        // Configure flash
        if let deviceInput = videoDeviceInput, deviceInput.device.isFlashAvailable {
            settings.flashMode = flashMode
        }
        
        // High quality capture
        settings.isHighResolutionPhotoEnabled = true
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecording() {
        guard isSessionRunning, !isRecording else { return }
        
        // Check if microphone is authorized
        let micStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        if micStatus != .authorized {
            AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.startRecordingVideo()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.error = .microphonePermissionDenied
                    }
                }
            }
        } else {
            startRecordingVideo()
        }
    }
    
    private func startRecordingVideo() {
        // Add audio input if not already added
        if session.inputs.filter({ $0.ports.contains(where: { $0.mediaType == .audio }) }).isEmpty {
            session.beginConfiguration()
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            session.commitConfiguration()
        }
        
        // Start recording
        videoOutput.startRecording(to: tempVideoURL, recordingDelegate: self)
        isRecording = true
    }
    
    func stopRecording() {
        guard isRecording else { return }
        videoOutput.stopRecording()
    }
    
    // MARK: - Media Management
    
    // Save image to app storage
    private func saveImageToAppStorage(_ image: UIImage) -> URL? {
        guard let photosDir = photosDirectory else {
            self.error = .fileSystemError(nil)
            return nil
        }
        
        let fileName = "photo_\(Date().timeIntervalSince1970).jpg"
        let fileURL = photosDir.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 0.9) else {
            self.error = .invalidPhotoData
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            self.error = .savePhoto(error)
            return nil
        }
    }
    
    // Save video to app storage
    private func saveVideoToAppStorage(from tempURL: URL) -> URL? {
        guard let videosDir = videosDirectory else {
            self.error = .fileSystemError(nil)
            return nil
        }
        
        let fileName = "video_\(Date().timeIntervalSince1970).mov"
        let fileURL = videosDir.appendingPathComponent(fileName)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            try FileManager.default.copyItem(at: tempURL, to: fileURL)
            return fileURL
        } catch {
            self.error = .saveVideo(error)
            return nil
        }
    }
    
    // Save current image to Photos library
    func saveCurrentImageToPhotos() {
        guard let image = currentImage else { return }
        
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // Save video to Photos library
    func saveVideoToPhotos(from url: URL) {
        UISaveVideoAtPathToSavedPhotosAlbum(
            url.path,
            self,
            #selector(self.video(_:didFinishSavingWithError:contextInfo:)),
            nil
        )
    }
    
    // Get all saved photos
    func getAllPhotos() -> [URL] {
        guard let photosDir = photosDirectory else { return [] }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: photosDir,
                includingPropertiesForKeys: nil
            )
            return fileURLs.filter { $0.pathExtension.lowercased() == "jpg" || $0.pathExtension.lowercased() == "jpeg" }
        } catch {
            self.error = .fileSystemError(error)
            return []
        }
    }
    
    // Get all saved videos
    func getAllVideos() -> [URL] {
        guard let videosDir = videosDirectory else { return [] }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: videosDir,
                includingPropertiesForKeys: nil
            )
            return fileURLs.filter { $0.pathExtension.lowercased() == "mov" || $0.pathExtension.lowercased() == "mp4" }
        } catch {
            self.error = .fileSystemError(error)
            return []
        }
    }
    
    // Delete a media file
    func deleteMedia(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            self.error = .fileSystemError(error)
            return false
        }
    }
    
    // Clean up old media files (older than one week)
    func cleanupOldMedia() {
        let oneWeekAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60) // 7 days
        
        // Clean photos
        cleanDirectory(photosDirectory, olderThan: oneWeekAgo)
        
        // Clean videos
        cleanDirectory(videosDirectory, olderThan: oneWeekAgo)
    }
    
    private func cleanDirectory(_ directory: URL?, olderThan date: Date) {
        guard let directory = directory else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: directory,
                includingPropertiesForKeys: [.creationDateKey]
            )
            
            for fileURL in fileURLs {
                if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                   let creationDate = attributes[.creationDate] as? Date,
                   creationDate < date {
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            self.error = .fileSystemError(error)
        }
    }
    
    // MARK: - Preview Layer
    
    func setPreviewLayer(for view: UIView) {
        if videoPreviewLayer == nil {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer = previewLayer
        }
        
        videoPreviewLayer?.frame = view.bounds
        
        if videoPreviewLayer?.superlayer == nil {
            view.layer.insertSublayer(videoPreviewLayer!, at: 0)
        }
    }
    
    func updatePreviewLayerFrame(for view: UIView) {
        videoPreviewLayer?.frame = view.bounds
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            self.error = .capturePhoto(error)
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            self.error = .invalidPhotoData
            return
        }
        
        self.currentImage = image
        
        // Save to app storage
        if let savedURL = saveImageToAppStorage(image) {
            self.lastSavedMediaURL = savedURL
            self.lastSavedMediaType = .photo
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.error = .savePhoto(error)
        }
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate

extension CameraManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            
            if let error = error {
                self.error = .recordVideo(error)
                return
            }
            
            // Save to app storage
            if let savedURL = self.saveVideoToAppStorage(from: outputFileURL) {
                self.lastSavedMediaURL = savedURL
                self.lastSavedMediaType = .video
            }
        }
    }
    
    @objc func video(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.error = .saveVideo(error)
        }
    }
}

// MARK: - Media Type Enum

enum MediaType {
    case photo
    case video
}

// MARK: - Error Types

enum CameraError: Error, Identifiable {
    case notAuthorized
    case cameraUnavailable
    case cannotAddInput
    case createCaptureInput(Error)
    case capturePhoto(Error)
    case invalidPhotoData
    case savePhoto(Error)
    case recordVideo(Error)
    case saveVideo(Error)
    case microphonePermissionDenied
    case fileSystemError(Error?)
    case unknown
    
    var id: String { localizedDescription }
    
    var localizedDescription: String {
        switch self {
        case .notAuthorized:
            return "Camera access not authorized"
        case .cameraUnavailable:
            return "Camera is unavailable"
        case .cannotAddInput:
            return "Cannot add camera input to session"
        case .createCaptureInput(let error):
            return "Error creating capture input: \(error.localizedDescription)"
        case .capturePhoto(let error):
            return "Error capturing photo: \(error.localizedDescription)"
        case .invalidPhotoData:
            return "Invalid photo data"
        case .savePhoto(let error):
            return "Error saving photo: \(error.localizedDescription)"
        case .recordVideo(let error):
            return "Error recording video: \(error.localizedDescription)"
        case .saveVideo(let error):
            return "Error saving video: \(error.localizedDescription)"
        case .microphonePermissionDenied:
            return "Microphone access not authorized"
        case .fileSystemError(let error):
            if let error = error {
                return "File system error: \(error.localizedDescription)"
            }
            return "File system error"
        case .unknown:
            return "Unknown camera error"
        }
    }
} 