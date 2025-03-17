import SwiftUI
import AVFoundation

struct DeviceCameraView: View {
    @StateObject private var cameraManager = CameraManager()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPhotoPreview = false
    @State private var showCameraSettings = false
    @State private var showPermissionAlert = false
    @State private var showMediaSavedAlert = false
    @State private var showSaveToPhotosConfirm = false
    @State private var mediaAlertMessage = ""
    
    var body: some View {
        ZStack {
            // Camera preview
            if cameraManager.isAuthorized {
                CameraPreviewView(cameraManager: cameraManager)
                    .edgesIgnoringSafeArea(.all)
                
                // Camera controls overlay
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
                        
                        Button(action: {
                            showCameraSettings = true
                        }) {
                            Image(systemName: "gear")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.trailing)
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack(spacing: 30) {
                        Spacer()
                        
                        // Photo button
                        Button(action: {
                            cameraManager.capturePhoto()
                        }) {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 70, height: 70)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: 60, height: 60)
                                )
                        }
                        
                        // Switch camera button
                        Button(action: {
                            cameraManager.switchCamera()
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
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
                            showSaveToPhotosConfirm = true
                        }
                    )
                }
            } else {
                // Camera not authorized view
                VStack(spacing: 20) {
                    Image(systemName: "camera.slash.fill")
                        .font(.system(size: 60))
                    
                    Text("Camera Access Required")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Please allow camera access in Settings to use this feature.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showPermissionAlert = true
                    }) {
                        Text("Open Settings")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top)
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .foregroundColor(.blue)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
        .onAppear {
            cameraManager.checkAuthorization()
        }
        .onChange(of: cameraManager.currentImage) { newImage in
            // Show photo preview when a new image is captured
            if newImage != nil {
                showPhotoPreview = true
            }
        }
        .onChange(of: cameraManager.lastSavedMediaURL) { url in
            if let url = url, let mediaType = cameraManager.lastSavedMediaType {
                let mediaTypeString = mediaType == .photo ? "Photo" : "Video"
                mediaAlertMessage = "\(mediaTypeString) saved to app storage"
                showMediaSavedAlert = true
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
                title: Text("Camera Access Required"),
                message: Text("Please allow camera access in Settings to use this feature."),
                primaryButton: .default(Text("Open Settings"), action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }),
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showMediaSavedAlert) {
            Alert(
                title: Text("Media Saved"),
                message: Text(mediaAlertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .actionSheet(isPresented: $showSaveToPhotosConfirm) {
            ActionSheet(
                title: Text("Save to Photos Library?"),
                message: Text("This media is already saved in the app. Do you want to save it to your Photos library as well?"),
                buttons: [
                    .default(Text("Save to Photos")) {
                        if let mediaType = cameraManager.lastSavedMediaType {
                            if mediaType == .photo {
                                cameraManager.saveCurrentImageToPhotos()
                            } else if mediaType == .video, let url = cameraManager.lastSavedMediaURL {
                                cameraManager.saveVideoToPhotos(from: url)
                            }
                            mediaAlertMessage = "Media saved to Photos library"
                            showMediaSavedAlert = true
                        }
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showCameraSettings) {
            CameraSettingsView()
        }
    }
}

struct DeviceCameraView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceCameraView()
    }
} 