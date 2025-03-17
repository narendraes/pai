import SwiftUI
import AVFoundation

struct DeviceCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPhotoPreview = false
    @State private var showCameraSettings = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        ZStack {
            // Camera preview
            if cameraManager.isAuthorized {
                CameraPreviewView(cameraManager: cameraManager)
                    .edgesIgnoringSafeArea(.all)
                
                // Camera controls overlay
                VStack {
                    // Top controls
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        
                        // Flash control
                        Button(action: {
                            switch cameraManager.flashMode {
                            case .off:
                                cameraManager.setFlashMode(.on)
                            case .on:
                                cameraManager.setFlashMode(.auto)
                            case .auto:
                                cameraManager.setFlashMode(.off)
                            @unknown default:
                                cameraManager.setFlashMode(.off)
                            }
                        }) {
                            Image(systemName: flashIcon)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack(spacing: 50) {
                        // Switch camera
                        CameraControlButton(
                            systemName: "arrow.triangle.2.circlepath.camera",
                            action: {
                                cameraManager.switchCamera()
                            }
                        )
                        
                        // Capture button
                        CaptureButton(
                            action: {
                                if cameraManager.isRecording {
                                    cameraManager.stopRecording()
                                } else {
                                    if cameraManager.isSessionRunning {
                                        cameraManager.capturePhoto()
                                    }
                                }
                            },
                            isRecording: cameraManager.isRecording
                        )
                        
                        // Record video
                        CameraControlButton(
                            systemName: cameraManager.isRecording ? "stop.circle.fill" : "video.circle.fill",
                            action: {
                                if cameraManager.isRecording {
                                    cameraManager.stopRecording()
                                } else {
                                    cameraManager.startRecording()
                                }
                            },
                            color: cameraManager.isRecording ? .red : .white
                        )
                    }
                    .padding(.bottom, 30)
                }
                
                // Photo preview if available
                if showPhotoPreview, let image = cameraManager.currentImage {
                    PhotoPreviewView(
                        image: image,
                        onDismiss: {
                            showPhotoPreview = false
                            cameraManager.currentImage = nil
                        },
                        onSave: {
                            // Image is already saved by the CameraManager
                            showPhotoPreview = false
                            cameraManager.currentImage = nil
                        }
                    )
                }
            } else {
                // Camera not authorized view
                VStack(spacing: 20) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.gray)
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Please allow access to your camera to use this feature.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            // Start camera session when view appears
            if cameraManager.isAuthorized {
                cameraManager.startSession()
            }
        }
        .onDisappear {
            // Stop camera session when view disappears
            cameraManager.stopSession()
        }
        .onChange(of: cameraManager.currentImage) { newImage in
            // Show photo preview when a new image is captured
            if newImage != nil {
                showPhotoPreview = true
            }
        }
        .onChange(of: cameraManager.error) { error in
            if error != nil {
                // Handle camera errors
                showPermissionAlert = error == .notAuthorized || error == .microphonePermissionDenied
            }
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text(cameraManager.error?.localizedDescription ?? "Camera access is required to use this feature."),
                primaryButton: .default(Text("Settings")) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // Helper to determine flash icon
    private var flashIcon: String {
        switch cameraManager.flashMode {
        case .on:
            return "bolt.fill"
        case .off:
            return "bolt.slash.fill"
        case .auto:
            return "bolt.badge.a.fill"
        @unknown default:
            return "bolt.slash.fill"
        }
    }
}

struct DeviceCameraView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceCameraView()
    }
} 