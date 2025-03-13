import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    @State private var showLogoutConfirmation = false
    @State private var showJailbreakAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $appState.settings.useDarkMode)
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $appState.settings.enableNotifications)
                }
                
                Section(header: Text("Recording")) {
                    Picker("Recording Quality", selection: $appState.settings.recordingQuality) {
                        Text("Low").tag(AppSettings.RecordingQuality.low)
                        Text("Medium").tag(AppSettings.RecordingQuality.medium)
                        Text("High").tag(AppSettings.RecordingQuality.high)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Security")) {
                    Button(action: {
                        showJailbreakAlert = DependencyContainer.shared.jailbreakDetectionService.isJailbroken()
                    }) {
                        HStack {
                            Text("Run Security Check")
                            Spacer()
                            Image(systemName: "shield")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Section(header: Text("Connection")) {
                    HStack {
                        Text("Status")
                        Spacer()
                        connectionStatusView
                    }
                    
                    Button(action: {
                        // Reconnect logic
                    }) {
                        Text("Reconnect")
                    }
                    .disabled(appState.connectionStatus == .connected || appState.connectionStatus == .connecting)
                }
                
                Section {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Logout", isPresented: $showLogoutConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .alert("Security Warning", isPresented: $showJailbreakAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This device appears to be jailbroken, which may compromise the security of your data.")
            }
        }
    }
    
    private var connectionStatusView: some View {
        HStack {
            switch appState.connectionStatus {
            case .connected:
                Circle()
                    .fill(Color.green)
                    .frame(width: 10, height: 10)
                Text("Connected")
                    .foregroundColor(.green)
            case .connecting:
                Circle()
                    .fill(Color.orange)
                    .frame(width: 10, height: 10)
                Text("Connecting...")
                    .foregroundColor(.orange)
            case .disconnected:
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                Text("Disconnected")
                    .foregroundColor(.red)
            case .error(let message):
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                Text("Error")
                    .foregroundColor(.red)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AppState())
            .environmentObject(AuthenticationViewModel())
    }
} 