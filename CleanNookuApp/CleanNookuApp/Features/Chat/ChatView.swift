import SwiftUI

struct ChatView: View {
    @EnvironmentObject var appState: AppState
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    
    var body: some View {
        VStack {
            // Chat messages
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding()
            }
            
            // Connection status indicator
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
            
            // Message input
            HStack {
                Button(action: {
                    // Attach media
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .padding(.leading)
                
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
        }
        .navigationTitle("Chat")
        .onAppear {
            // Add sample messages for demonstration
            if messages.isEmpty {
                messages = [
                    ChatMessage(id: UUID(), text: "Hello! How can I help you today?", isFromUser: false, timestamp: Date().addingTimeInterval(-3600)),
                    ChatMessage(id: UUID(), text: "I'd like to check my front door camera", isFromUser: true, timestamp: Date().addingTimeInterval(-3500)),
                    ChatMessage(id: UUID(), text: "Sure, I'll connect to your front door camera now.", isFromUser: false, timestamp: Date().addingTimeInterval(-3400))
                ]
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(id: UUID(), text: messageText, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear input field
        messageText = ""
        
        // Simulate response after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let responseText = "I've received your message. This is a simulated response since we're not connected to a real AI backend yet."
            let assistantMessage = ChatMessage(id: UUID(), text: responseText, isFromUser: false, timestamp: Date())
            messages.append(assistantMessage)
        }
    }
}

struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.isFromUser ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatView()
                .environmentObject(AppState())
        }
    }
}
