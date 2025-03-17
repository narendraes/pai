import SwiftUI
import AVFoundation
import Combine

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
                        self.error = NSError(domain: "CameraManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "No video device found"])
                    }
                }
                
                self.session.commitConfiguration()
                self.startSession()
                
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
    @State private var showDeviceCamera = false
    @State private var showMediaLibrary = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with device camera button
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
                }
                .padding(.trailing, 8)
                
                Button(action: {
                    showDeviceCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Webcam")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
        .sheet(isPresented: $showDeviceCamera) {
            DeviceCameraView()
        }
        .sheet(isPresented: $showMediaLibrary) {
            MediaLibraryView()
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
