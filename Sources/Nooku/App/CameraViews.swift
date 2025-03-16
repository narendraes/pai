import SwiftUI

// MARK: - Camera View
struct CameraView: View {
    let cameras = [
        Camera(id: "1", name: "Front Door", isOnline: true),
        Camera(id: "2", name: "Back Yard", isOnline: true),
        Camera(id: "3", name: "Garage", isOnline: false),
        Camera(id: "4", name: "Living Room", isOnline: true)
    ]
    
    @State private var selectedCamera: Camera?
    
    var body: some View {
        VStack {
            if let selectedCamera = selectedCamera {
                CameraDetailView(camera: selectedCamera) {
                    self.selectedCamera = nil
                }
            } else {
                // Camera list
                List(cameras) { camera in
                    Button(action: { selectedCamera = camera }) {
                        HStack {
                            Image(systemName: "video.fill")
                                .foregroundColor(camera.isOnline ? .green : .gray)
                            
                            VStack(alignment: .leading) {
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
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("Cameras")
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
            
            // Close button
            Button(action: onClose) {
                Text("Close")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .navigationTitle(camera.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Models
struct Camera: Identifiable {
    let id: String
    let name: String
    let isOnline: Bool
} 