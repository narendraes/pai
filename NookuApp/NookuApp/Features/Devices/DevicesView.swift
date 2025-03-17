import SwiftUI

struct DevicesView: View {
    @StateObject private var viewModel = DevicesViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.isLoading {
                    Section {
                        ForEach(0..<3) { _ in
                            DeviceRowSkeleton()
                        }
                    }
                } else if viewModel.devices.isEmpty {
                    Section {
                        Text("No devices found")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                } else {
                    Section(header: Text("Connected Devices")) {
                        ForEach(viewModel.devices) { device in
                            DeviceRow(device: device)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .refreshable {
                await viewModel.loadDevices()
            }
            .navigationTitle("Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await viewModel.loadDevices()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadDevices()
                }
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: iconForDevice(device))
                .font(.system(size: 24))
                .foregroundColor(colorForDevice(device))
                .frame(width: 40, height: 40)
                .background(colorForDevice(device).opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(device.name)
                    .font(.headline)
                
                Text(device.ipAddress)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(device.status)
                    .font(.caption)
                    .foregroundColor(device.status == "Online" ? .green : .orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(device.status == "Online" ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    .cornerRadius(4)
                
                Text("Last seen: \(timeAgoString(from: device.lastSeen))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func iconForDevice(_ device: Device) -> String {
        switch device.type {
        case "Mac":
            return "desktopcomputer"
        case "iPhone":
            return "iphone"
        case "iPad":
            return "ipad"
        case "Camera":
            return "video.fill"
        case "Speaker":
            return "homepod.fill"
        case "TV":
            return "tv.fill"
        default:
            return "network"
        }
    }
    
    private func colorForDevice(_ device: Device) -> Color {
        switch device.type {
        case "Mac":
            return .blue
        case "iPhone", "iPad":
            return .purple
        case "Camera":
            return .red
        case "Speaker":
            return .orange
        case "TV":
            return .green
        default:
            return .gray
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct DeviceRowSkeleton: View {
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 40, height: 40)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 14)
                    .frame(width: 120)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(width: 100)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 20)
                    .frame(width: 60)
                    .cornerRadius(4)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)
                    .frame(width: 80)
            }
        }
        .padding(.vertical, 8)
        .redacted(reason: .placeholder)
    }
}

struct DevicesView_Previews: PreviewProvider {
    static var previews: some View {
        DevicesView()
    }
} 