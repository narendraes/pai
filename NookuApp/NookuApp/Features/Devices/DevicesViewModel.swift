import Foundation

struct Device: Identifiable {
    let id = UUID()
    let name: String
    let ipAddress: String
    let type: String
    let status: String
    let lastSeen: Date
}

class DevicesViewModel: ObservableObject {
    @Published var devices: [Device] = []
    @Published var isLoading = false
    
    private let sshConnectionService: SSHConnectionServiceProtocol
    
    init(sshConnectionService: SSHConnectionServiceProtocol? = nil) {
        self.sshConnectionService = sshConnectionService ?? DependencyContainer.shared.sshConnectionService
    }
    
    @MainActor
    func loadDevices() async {
        isLoading = true
        
        // In a real app, we would fetch this data from the server
        // For now, we'll simulate with a delay and mock data
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        // Mock data
        devices = [
            Device(
                name: "Living Room Mac",
                ipAddress: "192.168.1.10",
                type: "Mac",
                status: "Online",
                lastSeen: Date()
            ),
            Device(
                name: "Kitchen iPad",
                ipAddress: "192.168.1.15",
                type: "iPad",
                status: "Online",
                lastSeen: Date()
            ),
            Device(
                name: "Front Door Camera",
                ipAddress: "192.168.1.20",
                type: "Camera",
                status: "Online",
                lastSeen: Date()
            ),
            Device(
                name: "Bedroom Speaker",
                ipAddress: "192.168.1.25",
                type: "Speaker",
                status: "Offline",
                lastSeen: Date().addingTimeInterval(-3600) // 1 hour ago
            ),
            Device(
                name: "Living Room TV",
                ipAddress: "192.168.1.30",
                type: "TV",
                status: "Online",
                lastSeen: Date()
            )
        ]
        
        isLoading = false
    }
} 