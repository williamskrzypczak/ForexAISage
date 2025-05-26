import SwiftUI

// MARK: - Chat Message Model
// Represents a single message in the chat interface
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String // The message text
    let isUser: Bool // Whether the message is from the user or AI
    let timestamp: Date // When the message was sent
}

// MARK: - Chat Bubble View
// Custom view for displaying individual chat messages
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            // Align user messages to the right, AI messages to the left
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                // Message content with custom styling
                Text(message.content)
                    .font(.title3)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(message.isUser ? Color.blue : Color.teal.opacity(0.4))
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                // Timestamp display
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

// MARK: - AI Sage View
// Main view for the AI-powered trading assistant
struct AISageView: View {
    // State management for chat
    @State private var messages: [ChatMessage] = [] // Chat history
    @State private var newMessage = "" // Current message input
    @State private var selectedChatType = 0 // Selected chat mode
    let chatTypes = ["Technical Analysis", "Trading Psychology"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // MARK: - Header Section
                // Brain icon and title display
                VStack {
                    Image(systemName: "brain.head.profile")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.teal)
                        .padding()
                        .background(
                            Circle()
                                .fill(Color.teal.opacity(0.1))
                        )
                        .frame(width: 160, height: 160)
                    
                    Text("AI Sage")
                        .font(.title)
                        .bold()
                        .foregroundColor(.teal)
                }
                .padding(.vertical)
                
                // MARK: - Chat Type Selection
                // Picker for selecting between technical analysis and trading psychology
                Picker("Chat Type", selection: $selectedChatType) {
                    ForEach(0..<chatTypes.count, id: \.self) { index in
                        Text(chatTypes[index])
                            .font(.title3)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                .shadow(radius: 2)
                .accentColor(.teal)
                
                // MARK: - Chat Interface
                // Messages display and input area
                VStack(spacing: 0) {
                    // Scrollable message history
                    ScrollView {
                        LazyVStack {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Message input area
                    HStack {
                        TextField("Type your message...", text: $newMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.teal)
                        }
                        .padding(.trailing)
                        .disabled(newMessage.isEmpty)
                    }
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: - Message Handling
    // Function to handle sending new messages
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(
            content: newMessage,
            isUser: true,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // Clear input field
        let sentMessage = newMessage
        newMessage = ""
        
        // Simulate AI response (in a real app, this would call an AI service)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = ChatMessage(
                content: "I'm analyzing your question about \(chatTypes[selectedChatType]). This is a placeholder response.",
                isUser: false,
                timestamp: Date()
            )
            messages.append(aiResponse)
        }
    }
}

// MARK: - Preview
#Preview {
    AISageView()
} 