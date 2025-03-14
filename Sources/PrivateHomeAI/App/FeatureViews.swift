import SwiftUI

// MARK: - Chat View
struct ChatView: View {
    @State private var message = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        VStack {
            // Chat history
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Input area
            HStack {
                TextField("Type a message...", text: $message)
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(20)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
        .onAppear {
            // Add some sample messages
            if messages.isEmpty {
                messages.append(ChatMessage(id: UUID(), text: "Hello! How can I help you today?", isUser: false, timestamp: Date()))
            }
        }
    }
    
    private func sendMessage() {
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(id: UUID(), text: message, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear input
        let userText = message
        message = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let responseText: String
            
            if userText.lowercased().contains("camera") {
                responseText = "I can help you with your cameras. Would you like to view a camera feed or check camera status?"
            } else if userText.lowercased().contains("security") {
                responseText = "Your home security system is active and all sensors are functioning normally."
            } else if userText.lowercased().contains("weather") {
                responseText = "I don't have access to weather data without your permission. Would you like to connect a weather service?"
            } else {
                responseText = "I'm processing your request locally. This ensures your data stays private and secure."
            }
            
            let aiMessage = ChatMessage(id: UUID(), text: responseText, isUser: false, timestamp: Date())
            messages.append(aiMessage)
        }
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(12)
                .background(message.isUser ? Color.blue : Color(UIColor.secondarySystemBackground))
                .foregroundColor(message.isUser ? .white : .primary)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isUser: Bool
    let timestamp: Date
}

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
                
                if !camera.isOnline {
                    VStack {
                        Image(systemName: "video.slash.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        
                        Text("Camera Offline")
                            .foregroundColor(.white)
                            .padding(.top, 8)
                    }
                } else {
                    // Simulated camera feed
                    Image(systemName: "house.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .opacity(0.6)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            Text(camera.name)
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(4)
                            
                            Spacer()
                            
                            Text(currentTimeString())
                                .foregroundColor(.white)
                                .padding(6)
                                .background(Color.black.opacity(0.6))
                                .cornerRadius(4)
                        }
                        .padding(8)
                    }
                    
                    // Recording indicator
                    if isRecording {
                        VStack {
                            HStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
                                
                                Text("REC")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(4)
                            .padding(8)
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // Controls
            HStack(spacing: 20) {
                Button(action: onClose) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: { isRecording.toggle() }) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "record.circle")
                        .font(.title)
                        .foregroundColor(isRecording ? .red : .blue)
                }
                
                Button(action: {}) {
                    Image(systemName: "camera.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Button(action: {}) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Camera info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Status:")
                    Spacer()
                    Text(camera.isOnline ? "Online" : "Offline")
                        .foregroundColor(camera.isOnline ? .green : .red)
                }
                
                HStack {
                    Text("Resolution:")
                    Spacer()
                    Text("1080p")
                }
                
                HStack {
                    Text("Last Motion:")
                    Spacer()
                    Text("2 minutes ago")
                }
                
                HStack {
                    Text("Storage:")
                    Spacer()
                    Text("45GB free")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
    
    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

struct Camera: Identifiable {
    let id: String
    let name: String
    let isOnline: Bool
}

// MARK: - Analysis View
struct AnalysisView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            Picker("Analysis Type", selection: $selectedTab) {
                Text("Scene").tag(0)
                Text("Objects").tag(1)
                Text("People").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                SceneAnalysisView()
            } else if selectedTab == 1 {
                ObjectAnalysisView()
            } else {
                PeopleAnalysisView()
            }
            
            Spacer()
        }
        .navigationTitle("Analysis")
    }
}

struct SceneAnalysisView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Scene Analysis")
                .font(.headline)
            
            // Upload button
            Button(action: {}) {
                VStack(spacing: 12) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 30))
                    
                    Text("Upload Image for Analysis")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            // Sample analysis results
            VStack(alignment: .leading, spacing: 12) {
                Text("Sample Analysis Results")
                    .font(.headline)
                
                HStack {
                    Text("Scene Type:")
                    Spacer()
                    Text("Indoor, Living Room")
                }
                
                HStack {
                    Text("Lighting:")
                    Spacer()
                    Text("Well lit, Natural light")
                }
                
                HStack {
                    Text("Time of Day:")
                    Spacer()
                    Text("Daytime")
                }
                
                HStack {
                    Text("Activity Level:")
                    Spacer()
                    Text("Low")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

struct ObjectAnalysisView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Object Detection")
                .font(.headline)
            
            // Sample image with objects
            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(4/3, contentMode: .fit)
                
                // Simulated object detection
                Image(systemName: "cube.box.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .opacity(0.6)
                
                // Bounding boxes
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    
                    // Chair
                    Rectangle()
                        .strokeBorder(Color.green, lineWidth: 2)
                        .frame(width: width * 0.3, height: height * 0.4)
                        .position(x: width * 0.3, y: height * 0.6)
                        .overlay(
                            Text("Chair: 92%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(2)
                                .background(Color.green)
                                .offset(y: -height * 0.2 - 10),
                            alignment: .center
                        )
                    
                    // Table
                    Rectangle()
                        .strokeBorder(Color.yellow, lineWidth: 2)
                        .frame(width: width * 0.5, height: height * 0.2)
                        .position(x: width * 0.6, y: height * 0.7)
                        .overlay(
                            Text("Table: 87%")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(2)
                                .background(Color.yellow)
                                .offset(y: -height * 0.1 - 10),
                            alignment: .center
                        )
                }
            }
            
            // Object list
            List {
                HStack {
                    Text("Chair")
                    Spacer()
                    Text("92%")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Table")
                    Spacer()
                    Text("87%")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Text("Lamp")
                    Spacer()
                    Text("76%")
                        .foregroundColor(.yellow)
                }
                
                HStack {
                    Text("Book")
                    Spacer()
                    Text("65%")
                        .foregroundColor(.yellow)
                }
            }
            .frame(height: 200)
            .listStyle(InsetGroupedListStyle())
        }
        .padding()
    }
}

struct PeopleAnalysisView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("People Detection")
                .font(.headline)
            
            // Privacy notice
            HStack {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.blue)
                
                Text("All analysis is performed locally for privacy")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom)
            
            // Sample stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Last 24 Hours")
                    .font(.headline)
                
                HStack {
                    Text("People Detected:")
                    Spacer()
                    Text("3")
                }
                
                HStack {
                    Text("Unknown Visitors:")
                    Spacer()
                    Text("1")
                        .foregroundColor(.yellow)
                }
                
                HStack {
                    Text("Detection Events:")
                    Spacer()
                    Text("12")
                }
                
                HStack {
                    Text("Last Detection:")
                    Spacer()
                    Text("10 minutes ago")
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            // Detection zones
            VStack(alignment: .leading, spacing: 12) {
                Text("Detection Zones")
                    .font(.headline)
                
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .aspectRatio(16/9, contentMode: .fit)
                    
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        // Front door zone
                        Path { path in
                            path.move(to: CGPoint(x: width * 0.2, y: height * 0.2))
                            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.2))
                            path.addLine(to: CGPoint(x: width * 0.4, y: height * 0.5))
                            path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.5))
                            path.closeSubpath()
                        }
                        .stroke(Color.green, lineWidth: 2)
                        .opacity(0.7)
                        
                        Text("Front Door")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(4)
                            .position(x: width * 0.3, y: height * 0.35)
                        
                        // Driveway zone
                        Path { path in
                            path.move(to: CGPoint(x: width * 0.6, y: height * 0.3))
                            path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.3))
                            path.addLine(to: CGPoint(x: width * 0.9, y: height * 0.7))
                            path.addLine(to: CGPoint(x: width * 0.6, y: height * 0.7))
                            path.closeSubpath()
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .opacity(0.7)
                        
                        Text("Driveway")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(4)
                            .background(Color.blue.opacity(0.7))
                            .cornerRadius(4)
                            .position(x: width * 0.75, y: height * 0.5)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var notificationsEnabled = true
    @State private var biometricAuthEnabled = true
    @State private var recordingQuality = 1
    @State private var autoArchiveEnabled = true
    @State private var showLogoutAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Account")) {
                HStack {
                    Text("Username")
                    Spacer()
                    Text("demo")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Server")
                    Spacer()
                    Text("localhost")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Connection Status")
                    Spacer()
                    Text(appState.connectionStatus.description)
                        .foregroundColor(appState.connectionStatus.color)
                }
            }
            
            Section(header: Text("Security")) {
                Toggle("Enable Biometric Authentication", isOn: $biometricAuthEnabled)
                
                NavigationLink(destination: Text("Security Test View")) {
                    Text("Security Tests")
                }
                
                NavigationLink(destination: Text("Encryption Settings")) {
                    Text("Encryption Settings")
                }
                
                NavigationLink(destination: Text("Keychain Management")) {
                    Text("Keychain Management")
                }
            }
            
            Section(header: Text("Notifications")) {
                Toggle("Enable Notifications", isOn: $notificationsEnabled)
                
                if notificationsEnabled {
                    NavigationLink(destination: Text("Notification Settings")) {
                        Text("Notification Settings")
                    }
                }
            }
            
            Section(header: Text("Recording")) {
                Picker("Recording Quality", selection: $recordingQuality) {
                    Text("Low (720p)").tag(0)
                    Text("Medium (1080p)").tag(1)
                    Text("High (4K)").tag(2)
                }
                
                Toggle("Auto-Archive Recordings", isOn: $autoArchiveEnabled)
                
                NavigationLink(destination: Text("Storage Management")) {
                    Text("Storage Management")
                }
            }
            
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.gray)
                }
                
                NavigationLink(destination: Text("Privacy Policy")) {
                    Text("Privacy Policy")
                }
                
                NavigationLink(destination: Text("Terms of Service")) {
                    Text("Terms of Service")
                }
            }
            
            Section {
                Button(action: { showLogoutAlert = true }) {
                    Text("Logout")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Logout"),
                message: Text("Are you sure you want to logout?"),
                primaryButton: .destructive(Text("Logout")) {
                    logout()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func logout() {
        // Perform logout
        withAnimation {
            appState.isAuthenticated = false
            appState.isConnected = false
            appState.connectionStatus = .disconnected
        }
    }
} 