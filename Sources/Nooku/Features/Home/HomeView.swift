import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authViewModel: AuthenticationViewModel
    
    @State private var systemStatus: SystemStatus = .loading
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var diskUsage: Double = 0.0
    @State private var activeModels: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Connection status card
                    ConnectionStatusCard(status: appState.connectionStatus)
                    
                    // System metrics
                    SystemMetricsCard(
                        cpuUsage: cpuUsage,
                        memoryUsage: memoryUsage,
                        diskUsage: diskUsage
                    )
                    
                    // Active models
                    ActiveModelsCard(models: activeModels)
                    
                    // Quick actions
                    QuickActionsCard(onRefresh: refreshData)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .onAppear {
                refreshData()
            }
        }
    }
    
    private func refreshData() {
        // In a real app, this would fetch data from the server
        // For now, we'll simulate with random values
        
        // Simulate loading
        systemStatus = .loading
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Random values for demo
            cpuUsage = Double.random(in: 10...80)
            memoryUsage = Double.random(in: 20...90)
            diskUsage = Double.random(in: 30...70)
            
            activeModels = [
                "llama2-7b",
                "mistral-7b",
                "codellama-7b"
            ]
            
            systemStatus = .online
        }
    }
}

enum SystemStatus {
    case loading
    case online
    case offline
    case error(String)
}

struct ConnectionStatusCard: View {
    let status: ConnectionStatus
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Connection Status")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                switch status {
                case .connected:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Connected")
                        .foregroundColor(.green)
                case .connecting:
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.orange)
                    Text("Connecting...")
                        .foregroundColor(.orange)
                case .disconnected:
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Disconnected")
                        .foregroundColor(.red)
                case .error(let message):
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Error: \(message)")
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct SystemMetricsCard: View {
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("System Metrics")
                .font(.headline)
                .padding(.bottom, 5)
            
            VStack(spacing: 15) {
                MetricRow(label: "CPU", value: cpuUsage, icon: "cpu")
                MetricRow(label: "Memory", value: memoryUsage, icon: "memorychip")
                MetricRow(label: "Disk", value: diskUsage, icon: "internaldrive")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct MetricRow: View {
    let label: String
    let value: Double
    let icon: String
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Image(systemName: icon)
                Text(label)
                Spacer()
                Text("\(Int(value))%")
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: value, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: colorForValue(value)))
        }
    }
    
    private func colorForValue(_ value: Double) -> Color {
        if value < 50 {
            return .green
        } else if value < 80 {
            return .orange
        } else {
            return .red
        }
    }
}

struct ActiveModelsCard: View {
    let models: [String]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Models")
                .font(.headline)
                .padding(.bottom, 5)
            
            if models.isEmpty {
                HStack {
                    Spacer()
                    Text("No active models")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical)
            } else {
                ForEach(models, id: \.self) { model in
                    HStack {
                        Image(systemName: "brain")
                        Text(model)
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 5)
                    
                    if model != models.last {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct QuickActionsCard: View {
    let onRefresh: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack(spacing: 15) {
                QuickActionButton(
                    title: "Refresh",
                    icon: "arrow.clockwise",
                    color: .blue,
                    action: onRefresh
                )
                
                QuickActionButton(
                    title: "Pull Model",
                    icon: "arrow.down.circle",
                    color: .purple
                )
                
                QuickActionButton(
                    title: "Settings",
                    icon: "gear",
                    color: .gray
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                    .frame(height: 30)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemBackground))
            .cornerRadius(8)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(AppState())
            .environmentObject(AuthenticationViewModel())
    }
} 