import SwiftUI

struct CameraView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCamera = 0
    @State private var isRecording = false
    @State private var showSettings = false
    
    // Sample camera data
    private let cameras = [
        Camera(id: "front_door", name: "Front Door", isOnline: true),
        Camera(id: "back_yard", name: "Back Yard", isOnline: true),
        Camera(id: "garage", name: "Garage", isOnline: false),
        Camera(id: "living_room", name: "Living Room", isOnline: true)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Camera selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(0..<cameras.count, id: \.self) { index in
                        CameraButton(
                            camera: cameras[index],
                            isSelected: selectedCamera == index
                        ) {
                            selectedCamera = index
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
            .background(Color(.systemGray6))
            
            // Camera feed
            ZStack {
                // Camera placeholder
                Rectangle()
                    .fill(Color.black)
                
                VStack {
                    // Camera name and status
                    HStack {
                        Text(cameras[selectedCamera].name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Circle()
                            .fill(cameras[selectedCamera].isOnline ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                        
                        Text(cameras[selectedCamera].isOnline ? "Online" : "Offline")
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            showSettings.toggle()
                        }) {
                            Image(systemName: "gear")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    
                    Spacer()
                    
                    // If camera is offline
                    if !cameras[selectedCamera].isOnline {
                        Text("Camera Offline")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                    
                    // Camera controls
                    HStack(spacing: 30) {
                        Button(action: {
                            // Take snapshot
                        }) {
                            VStack {
                                Image(systemName: "camera")
                                    .font(.system(size: 24))
                                Text("Snapshot")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            isRecording.toggle()
                        }) {
                            VStack {
                                Image(systemName: isRecording ? "stop.circle" : "record.circle")
                                    .font(.system(size: 24))
                                    .foregroundColor(isRecording ? .red : .white)
                                Text(isRecording ? "Stop" : "Record")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        .disabled(!cameras[selectedCamera].isOnline)
                        
                        Button(action: {
                            // Toggle audio
                        }) {
                            VStack {
                                Image(systemName: "speaker.wave.2")
                                    .font(.system(size: 24))
                                Text("Audio")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        .disabled(!cameras[selectedCamera].isOnline)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Connection status
            if !appState.isConnected {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Not connected to server")
                        .font(.caption)
                    Spacer()
                    Button("Connect") {
                        appState.connect()
                    }
                    .font(.caption)
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
        }
        .navigationTitle("Cameras")
        .sheet(isPresented: $showSettings) {
            CameraSettingsView(camera: cameras[selectedCamera])
        }
    }
}

struct Camera: Identifiable {
    let id: String
    let name: String
    let isOnline: Bool
}

struct CameraButton: View {
    let camera: Camera
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "video.fill")
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    // Status indicator
                    Circle()
                        .fill(camera.isOnline ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: 20, y: -20)
                }
                
                Text(camera.name)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .primary)
                    .lineLimit(1)
            }
            .frame(width: 70)
        }
    }
}

struct CameraSettingsView: View {
    let camera: Camera
    @Environment(\.presentationMode) var presentationMode
    @State private var recordingQuality = 1 // 0: Low, 1: Medium, 2: High
    @State private var motionDetection = true
    @State private var notifications = true
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Camera Info")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(camera.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(camera.isOnline ? "Online" : "Offline")
                            .foregroundColor(camera.isOnline ? .green : .red)
                    }
                    
                    HStack {
                        Text("ID")
                        Spacer()
                        Text(camera.id)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Recording Settings")) {
                    Picker("Quality", selection: $recordingQuality) {
                        Text("Low").tag(0)
                        Text("Medium").tag(1)
                        Text("High").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Toggle("Motion Detection", isOn: $motionDetection)
                    Toggle("Notifications", isOn: $notifications)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        recordingQuality = 1
                        motionDetection = true
                        notifications = true
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
        NavigationView {
            CameraView()
                .environmentObject(AppState())
        }
    }
}
