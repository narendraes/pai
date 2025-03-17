import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var serverAddress = "192.168.1.100"
    @State private var serverPort = "22"
    @State private var username = "admin"
    @State private var password = "••••••••"
    @State private var showPassword = false
    @State private var autoConnect = true
    @State private var showResetAlert = false
    
    var body: some View {
        Form {
            // Connection settings
            Section(header: Text("Connection Settings")) {
                HStack {
                    Text("Status")
                    Spacer()
                    HStack {
                        Circle()
                            .fill(appState.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(appState.isConnected ? "Connected" : "Disconnected")
                            .foregroundColor(appState.isConnected ? .green : .red)
                    }
                }
                
                TextField("Server Address", text: $serverAddress)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                TextField("Port", text: $serverPort)
                    .keyboardType(.numberPad)
                
                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                
                HStack {
                    if showPassword {
                        TextField("Password", text: $password)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    } else {
                        SecureField("Password", text: $password)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle("Auto Connect", isOn: $autoConnect)
                
                Button(action: {
                    if appState.isConnected {
                        appState.disconnect()
                    } else {
                        appState.connect()
                    }
                }) {
                    Text(appState.isConnected ? "Disconnect" : "Connect")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            
            // App settings
            Section(header: Text("App Settings")) {
                Toggle("Dark Mode", isOn: $appState.settings.useDarkMode)
                Toggle("Notifications", isOn: $appState.settings.enableNotifications)
                
                Picker("Recording Quality", selection: $appState.settings.recordingQuality) {
                    Text("Low").tag(AppState.AppSettings.RecordingQuality.low)
                    Text("Medium").tag(AppState.AppSettings.RecordingQuality.medium)
                    Text("High").tag(AppState.AppSettings.RecordingQuality.high)
                }
            }
            
            // Security settings
            Section(header: Text("Security")) {
                Toggle("Biometric Authentication", isOn: .constant(true))
                Toggle("Jailbreak Detection", isOn: .constant(true))
                    .disabled(true)
                
                Button(action: {
                    // Perform security scan
                }) {
                    Text("Run Security Scan")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // Storage settings
            Section(header: Text("Storage")) {
                HStack {
                    Text("Used Space")
                    Spacer()
                    Text("1.2 GB")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Available Space")
                    Spacer()
                    Text("45.8 GB")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    // Clear cache
                }) {
                    Text("Clear Cache")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            
            // About section
            Section(header: Text("About")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Build")
                    Spacer()
                    Text("2023.1")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    // Open privacy policy
                }) {
                    Text("Privacy Policy")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    // Open terms of service
                }) {
                    Text("Terms of Service")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                }
            }
            
            // Reset section
            Section {
                Button(action: {
                    showResetAlert = true
                }) {
                    Text("Reset All Settings")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .alert("Reset Settings", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                resetSettings()
            }
        } message: {
            Text("Are you sure you want to reset all settings to default values? This action cannot be undone.")
        }
    }
    
    private func resetSettings() {
        // Reset connection settings
        serverAddress = "192.168.1.100"
        serverPort = "22"
        username = "admin"
        password = "••••••••"
        autoConnect = true
        
        // Reset app settings
        appState.settings.useDarkMode = true
        appState.settings.enableNotifications = true
        appState.settings.recordingQuality = .high
        
        // Disconnect if connected
        if appState.isConnected {
            appState.disconnect()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
                .environmentObject(AppState())
        }
    }
}
