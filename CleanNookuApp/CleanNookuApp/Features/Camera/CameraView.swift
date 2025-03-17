import SwiftUI
import AVFoundation
import Combine
import UIKit

// Define Camera model directly in this file
struct Camera: Identifiable {
    let id: String
    let name: String
    let isOnline: Bool
    let type: CameraType
    
    init(id: String, name: String, isOnline: Bool, type: CameraType = .external) {
        self.id = id
        self.name = name
        self.isOnline = isOnline
        self.type = type
    }
}

enum CameraType {
    case device // Built-in device camera
    case external // External IP camera
}

// Camera Preview View for showing webcam feed
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Camera Manager to handle webcam access
class CameraManager: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var isSessionRunning = false
    @Published var error: Error?
    
    let session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput?
    
    override init() {
        super.init()
        print("CameraManager initialized")
    }
    
    func checkAuthorization() {
        print("Checking camera authorization")
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            print("Camera access already authorized")
            DispatchQueue.main.async {
                self.isAuthorized = true
            }
            self.setupCaptureSession()
        case .notDetermined:
            print("Camera access not determined, requesting...")
            AVCaptureDevice.requestAccess(for: .video) { granted in
                print("Camera access request result: \(granted)")
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupCaptureSession()
                    } else {
                        print("Camera access denied by user")
                    }
                }
            }
        case .denied:
            print("Camera access denied")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        case .restricted:
            print("Camera access restricted")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        @unknown default:
            print("Camera access unknown status")
            DispatchQueue.main.async {
                self.isAuthorized = false
            }
        }
    }
    
    private func setupCaptureSession() {
        print("Setting up capture session")
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            do {
                self.session.beginConfiguration()
                
                // Check if running in simulator
                #if targetEnvironment(simulator)
                print("Running in simulator - camera not available")
                DispatchQueue.main.async {
                    self.error = NSError(domain: "CameraManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Camera not available in simulator. Please run on a physical device."])
                }
                #else
                // Add video input
                if let videoDevice = AVCaptureDevice.default(for: .video) {
                    print("Found video device: \(videoDevice.localizedName)")
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                        print("Added video input to session")
                    } else {
                        print("Could not add video input to session")
                        DispatchQueue.main.async {
                            self.error = NSError(domain: "CameraManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not add video input to session"])
                        }
                    }
                } else {
                    print("No video device found")
                    DispatchQueue.main.async {
                        self.error = NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No video device found. Please check your device's camera."])
                    }
                }
                #endif
                
                self.session.commitConfiguration()
                
                // Only start session if not in simulator and no error
                #if !targetEnvironment(simulator)
                if self.error == nil {
                    self.startSession()
                }
                #endif
                
            } catch {
                print("Error setting up capture session: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }
    }
    
    func startSession() {
        print("Starting camera session")
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                self.session.startRunning()
                print("Camera session running: \(self.session.isRunning)")
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    func stopSession() {
        print("Stopping camera session")
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                
                self.session.stopRunning()
                print("Camera session stopped")
                DispatchQueue.main.async {
                    self.isSessionRunning = self.session.isRunning
                }
            }
        }
    }
    
    func switchCamera() {
        // Implementation for switching between front and back cameras
        // (Not implemented for this simplified version)
    }
}

// Define DeviceCameraView
struct DeviceCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(.systemBackground).edgesIgnoringSafeArea(.all)
            
            // Camera content based on state
            Group {
                if cameraManager.isAuthorized {
                    if cameraManager.error == nil {
                        // Camera preview
                        ZStack {
                            CameraPreviewView(session: cameraManager.session)
                                .edgesIgnoringSafeArea(.all)
                            
                            // Close button
                            VStack {
                                HStack {
                                    Button(action: {
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Image(systemName: "xmark")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.top, 30)
                                
                                Spacer()
                            }
                        }
                    } else {
                        // Error view
                        ErrorView(
                            errorMessage: cameraManager.error?.localizedDescription ?? "Unknown error",
                            onClose: { presentationMode.wrappedValue.dismiss() }
                        )
                    }
                } else {
                    // Camera not authorized view
                    NotAuthorizedView(
                        onOpenSettings: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        },
                        onCancel: { presentationMode.wrappedValue.dismiss() }
                    )
                }
            }
        }
        .onAppear {
            print("DeviceCameraView appeared")
            cameraManager.checkAuthorization()
        }
        .onDisappear {
            print("DeviceCameraView disappeared")
            cameraManager.stopSession()
        }
    }
}

// Error View
struct ErrorView: View {
    let errorMessage: String
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Camera Error")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(errorMessage)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            #if targetEnvironment(simulator)
            Text("Note: Camera functionality requires a physical device.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            #endif
            
            Button(action: onClose) {
                Text("Close")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top)
        }
        .padding()
    }
}

// Not Authorized View
struct NotAuthorizedView: View {
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.metering.none")
                .font(.system(size: 60))
            
            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Please allow camera access in Settings to use this feature.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onOpenSettings) {
                Text("Open Settings")
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.top)
            
            Button(action: onCancel) {
                Text("Cancel")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}

// Define MediaLibraryView
struct MediaLibraryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Media Library")
                .font(.title)
                .padding()
            
            Spacer()
            
            Text("Media library placeholder")
                .foregroundColor(.gray)
            
            Spacer()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct CameraView: View {
    @EnvironmentObject var appState: AppState
    
    // Sample camera data
    private let cameras = [
        Camera(id: "front_door", name: "Front Door", isOnline: false),
        Camera(id: "back_yard", name: "Back Yard", isOnline: false),
        Camera(id: "garage", name: "Garage", isOnline: false),
        Camera(id: "living_room", name: "Living Room", isOnline: false)
    ]
    
    @State private var selectedCamera: Camera?
    @State private var showMediaLibrary = false
    @State private var showMacCamera = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Mac camera button
            HStack {
                Text("Cameras")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    showMediaLibrary = true
                }) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .frame(width: 44, height: 44)
                }
                
                Button(action: {
                    showMacCamera = true
                }) {
                    Image(systemName: "laptopcomputer")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            
            // Camera list
            if let selectedCamera = selectedCamera {
                // Show selected camera detail
                CameraDetailView(camera: selectedCamera) {
                    self.selectedCamera = nil
                }
            } else {
                // Show camera list with disabled cameras
                VStack {
                    List {
                        ForEach(cameras) { camera in
                            CameraListItem(camera: camera)
                                .onTapGesture {
                                    // Disabled for now
                                }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    
                    Text("External cameras are currently disabled")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom)
                }
            }
        }
        .sheet(isPresented: $showMediaLibrary) {
            MediaLibraryView()
        }
        .sheet(isPresented: $showMacCamera) {
            MacCameraView()
        }
    }
}

struct CameraListItem: View {
    let camera: Camera
    
    var body: some View {
        HStack {
            Image(systemName: "video.fill")
                .font(.title2)
                .foregroundColor(camera.isOnline ? .green : .gray)
                .frame(width: 40, height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(camera.name)
                    .font(.headline)
                
                Text(camera.isOnline ? "Online" : "Offline")
                    .font(.caption)
                    .foregroundColor(camera.isOnline ? .green : .gray)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct CameraDetailView: View {
    let camera: Camera
    let onClose: () -> Void
    
    @State private var isRecording = false
    
    var body: some View {
        VStack {
            // Camera feed (placeholder)
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(16/9, contentMode: .fit)
                
                if camera.isOnline {
                    // Placeholder for camera feed
                    Image(systemName: "video.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                } else {
                    // Offline message
                    VStack {
                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text("Camera Offline")
                            .foregroundColor(.white)
                            .padding(.top, 10)
                    }
                }
                
                // Recording indicator
                if isRecording {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                        .padding(8)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(20)
                        .position(x: 30, y: 30)
                }
                
                // Close button
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .position(x: 30, y: 30)
            }
            .cornerRadius(12)
            .padding()
            
            // Controls
            HStack(spacing: 30) {
                Button(action: {
                    // Take snapshot
                }) {
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        Text("Snapshot")
                            .font(.caption)
                    }
                }
                .disabled(!camera.isOnline)
                
                Button(action: {
                    isRecording.toggle()
                }) {
                    VStack {
                        Image(systemName: isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 24))
                            .foregroundColor(isRecording ? .red : .primary)
                        Text(isRecording ? "Stop" : "Record")
                            .font(.caption)
                    }
                }
                .disabled(!camera.isOnline)
                
                Button(action: {
                    // Open settings
                }) {
                    VStack {
                        Image(systemName: "gear")
                            .font(.system(size: 24))
                        Text("Settings")
                            .font(.caption)
                    }
                }
            }
            .padding()
            
            // Camera info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Status:")
                        .fontWeight(.bold)
                    Text(camera.isOnline ? "Online" : "Offline")
                        .foregroundColor(camera.isOnline ? .green : .red)
                }
                
                HStack {
                    Text("Resolution:")
                        .fontWeight(.bold)
                    Text(camera.isOnline ? "1080p" : "N/A")
                }
                
                HStack {
                    Text("Last Motion:")
                        .fontWeight(.bold)
                    Text(camera.isOnline ? "2 minutes ago" : "N/A")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
            
            Spacer()
        }
    }
}

struct CameraSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var recordingQuality = 1 // 0: Low, 1: Medium, 2: High
    @State private var saveToPhotos = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recording Settings")) {
                    Picker("Quality", selection: $recordingQuality) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("Save to Photos", isOn: $saveToPhotos)
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Camera Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
            .environmentObject(AppState())
    }
}

// Simple MacCameraView implementation
struct MacCameraView: View {
    @ObservedObject private var macClient = MacServerClient.shared
    @State private var selectedCameraId: String?
    @Environment(\.presentationMode) private var presentationMode
    @State private var showDebug = false
    @State private var isLoading = false
    @State private var lastErrorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Connecting...")
                            .padding()
                        Spacer()
                    }
                } else {
                    // Status indicator
                    HStack {
                        Circle()
                            .fill(macClient.isConnected ? Color.green : Color.red)
                            .frame(width: 12, height: 12)
                        
                        Text(macClient.isConnected ? "Connected" : "Not Connected")
                            .font(.subheadline)
                            .foregroundColor(macClient.isConnected ? .green : .red)
                    }
                    .padding(.top, 12)
                
                    if macClient.isConnected {
                        if let image = macClient.currentImage {
                            ZStack(alignment: .bottom) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                
                                // Capture button
                                Button(action: {
                                    takePhoto()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 70, height: 70)
                                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 2)
                                        
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                                            .frame(width: 60, height: 60)
                                        
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 52, height: 52)
                                        
                                        Image(systemName: "camera")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    .contentShape(Circle())
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.bottom, 20)
                            }
                        } else {
                            VStack {
                                Spacer()
                                Text("No camera preview available")
                                    .foregroundColor(.gray)
                                    .padding()
                                
                                Button("Refresh Preview") {
                                    refreshPreview()
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.bottom, 20)
                                Spacer()
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            Spacer()
                            Image(systemName: "laptopcomputer.slash")
                                .font(.system(size: 60))
                                .foregroundColor(.red.opacity(0.7))
                            
                            Text("Not connected to Mac server")
                                .font(.headline)
                                .foregroundColor(.red)
                            
                            if let errorMessage = lastErrorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Button("Connect") {
                                connectToServer()
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top)
                            
                            Button("Test Connection") {
                                testConnection()
                            }
                            .buttonStyle(.bordered)
                            Spacer()
                        }
                        .padding()
                    }
                
                    Spacer()
                    
                    // Debug section
                    if showDebug {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Debug Info")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal)
                            
                            ScrollView {
                                Text(macClient.debugMessage)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(8)
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(8)
                            }
                            .frame(height: 120)
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 8)
                    }
                    
                    // Toggle debug info
                    Toggle("Show Debug Info", isOn: $showDebug)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                }
            }
            .navigationTitle("Mac Camera")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                macClient.debugMessage = "View appeared"
                connectToServer()
            }
            .alert(item: $macClient.alertItem) { alertItem in
                Alert(
                    title: Text(alertItem.title),
                    message: Text(alertItem.message),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    private func connectToServer() {
        isLoading = true
        macClient.debugMessage += "\nAttempting to connect..."
        
        macClient.checkConnection()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        lastErrorMessage = error.localizedDescription
                        macClient.debugMessage += "\nConnection check failed: \(error.localizedDescription)"
                    } else {
                        lastErrorMessage = nil
                    }
                    
                    if macClient.isConnected {
                        refreshCameras()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &macClient.cancellables)
    }
    
    private func testConnection() {
        isLoading = true
        // Try connecting via standard URL
        let testURLs = [
            "http://192.168.5.110:8080/health",
            "http://127.0.0.1:8080/health",
            "http://localhost:8080/health"
        ]
        
        macClient.debugMessage = "Testing connections..."
        var successFound = false
        
        for (index, urlString) in testURLs.enumerated() {
            guard let url = URL(string: urlString) else { continue }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        macClient.debugMessage += "\nTest \(index+1) failed: \(error.localizedDescription)"
                    } else if let httpResponse = response as? HTTPURLResponse {
                        let responseData = data != nil ? String(data: data!, encoding: .utf8) ?? "No data" : "No data"
                        macClient.debugMessage += "\nTest \(index+1): HTTP \(httpResponse.statusCode), response: \(responseData)"
                        
                        if httpResponse.statusCode == 200 {
                            successFound = true
                            if !macClient.isConnected {
                                // If we found a working URL, try to update server URL and connect
                                if let url = URL(string: urlString.replacingOccurrences(of: "/health", with: "")) {
                                    macClient.updateServerURL(url)
                                    connectToServer()
                                }
                            }
                        }
                    } else {
                        macClient.debugMessage += "\nTest \(index+1): Unknown response type"
                    }
                    
                    // If this is the last URL and we're still loading
                    if index == testURLs.count - 1 {
                        isLoading = false
                    }
                }
            }
            task.resume()
        }
    }
    
    private func refreshCameras() {
        isLoading = true
        macClient.listCameras()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    isLoading = false
                    if case .failure(let error) = completion {
                        macClient.debugMessage += "\nFailed to list cameras: \(error.localizedDescription)"
                    }
                },
                receiveValue: { cameras in
                    if let firstCamera = cameras.first {
                        selectCamera(firstCamera.id)
                    }
                }
            )
            .store(in: &macClient.cancellables)
    }
    
    private func selectCamera(_ cameraId: String) {
        macClient.selectCamera(cameraId: cameraId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        macClient.debugMessage += "\nFailed to select camera: \(error.localizedDescription)"
                    }
                },
                receiveValue: { success in
                    if success {
                        selectedCameraId = cameraId
                        refreshPreview()
                    }
                }
            )
            .store(in: &macClient.cancellables)
    }
    
    private func refreshPreview() {
        macClient.takeSnapshot()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        macClient.debugMessage += "\nFailed to take snapshot: \(error.localizedDescription)"
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &macClient.cancellables)
    }
    
    private func takePhoto() {
        macClient.takeSnapshot()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        macClient.debugMessage += "\nFailed to take photo: \(error.localizedDescription)"
                        macClient.showAlert(title: "Error", message: "Failed to take photo: \(error.localizedDescription)")
                    } else {
                        // Success - save to photos
                        if let image = macClient.currentImage {
                            ImageSaver().saveImage(image) { result in
                                DispatchQueue.main.async {
                                    switch result {
                                    case .success:
                                        macClient.showAlert(title: "Success", message: "Photo saved to your library")
                                    case .failure(let error):
                                        macClient.showAlert(title: "Error", message: "Failed to save photo: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &macClient.cancellables)
    }
}

// Alert item for showing alerts
struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

// Basic MacServerClient implementation for Mac camera access
class MacServerClient: ObservableObject {
    // MARK: - Properties
    static let shared = MacServerClient()
    
    @Published var isConnected = false
    @Published var availableCameras: [MacCamera] = []
    @Published var currentImage: UIImage?
    @Published var error: Error?
    @Published var debugMessage: String = ""
    @Published var alertItem: AlertItem?
    
    var cancellables = Set<AnyCancellable>()
    
    private var serverURL = URL(string: "http://192.168.5.110:8080")!
    private var apiKey = "test-api-key"
    private let session: URLSession
    
    init() {
        debugMessage = "Initializing with URL: \(serverURL.absoluteString)"
        
        // Configure URL session with more permissive settings
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Methods
    func checkConnection() -> AnyPublisher<Bool, Error> {
        let url = serverURL.appendingPathComponent("health")
        debugMessage = "Checking connection to: \(url.absoluteString)"
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse else {
                    self.debugMessage += "\nInvalid response type"
                    throw URLError(.badServerResponse)
                }
                
                self.debugMessage += "\nReceived HTTP \(httpResponse.statusCode)"
                
                guard httpResponse.statusCode == 200 else {
                    self.debugMessage += "\nInvalid status code: \(httpResponse.statusCode)"
                    throw URLError(.badServerResponse)
                }
                
                let responseString = String(data: data, encoding: .utf8) ?? "No data"
                self.debugMessage += "\nServer response: \(responseString)"
                return true
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] isConnected in
                self?.isConnected = isConnected
                self?.debugMessage += "\nConnection successful: \(isConnected)"
            }, receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.debugMessage += "\nConnection error: \(error.localizedDescription)"
                }
            })
            .eraseToAnyPublisher()
    }
    
    func listCameras() -> AnyPublisher<[MacCamera], Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras")
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: CameraListResponse.self, decoder: JSONDecoder())
            .map { $0.data }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] cameras in
                self?.availableCameras = cameras
            })
            .eraseToAnyPublisher()
    }
    
    func selectCamera(cameraId: String) -> AnyPublisher<Bool, Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras/select")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["cameraId": cameraId]
        request.httpBody = try? JSONEncoder().encode(body)
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> Bool in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return true
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func takeSnapshot() -> AnyPublisher<UIImage, Error> {
        let url = serverURL.appendingPathComponent("api/v1/cameras/snapshot")
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-Key")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { data, response -> UIImage in
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200,
                      let image = UIImage(data: data) else {
                    throw URLError(.badServerResponse)
                }
                return image
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] image in
                self?.currentImage = image
            })
            .eraseToAnyPublisher()
    }
    
    func updateServerURL(_ newURL: URL) {
        serverURL = newURL
        debugMessage = "Updated server URL to: \(serverURL.absoluteString)"
    }
    
    func showAlert(title: String, message: String) {
        alertItem = AlertItem(title: title, message: message)
    }
}

// Models needed for MacServerClient
struct MacCamera: Identifiable, Codable {
    let id: String
    let name: String
    let position: String
}

struct CameraListResponse: Codable {
    let success: Bool
    let data: [MacCamera]
}

// Photo Saver Helper
class ImageSaver: NSObject {
    private var completion: ((Result<Void, Error>) -> Void)?
    
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        self.completion = completion
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            completion?(.failure(error))
        } else {
            completion?(.success(()))
        }
        
        // Break reference cycle
        completion = nil
    }
}
