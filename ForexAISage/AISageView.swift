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
    @Environment(\.colorScheme) var colorScheme
    
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
                            .fill(message.isUser ? 
                                (colorScheme == .dark ? Color.blue.opacity(0.8) : Color.blue) :
                                (colorScheme == .dark ? Color.teal.opacity(0.3) : Color.teal.opacity(0.4))
                            )
                    )
                    .foregroundColor(message.isUser ? .white : .primary)
                    .cornerRadius(20)
                
                // Timestamp display
                Text(message.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
            }
            
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

// MARK: - Chat Box View
struct ChatBoxView: View {
    let title: String
    let messages: [ChatMessage]
    @Binding var newMessage: String
    let onSend: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            Text(title)
                .font(.headline)
                .foregroundColor(.teal)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(colorScheme == .dark ? Color.teal.opacity(0.2) : Color.teal.opacity(0.1))
            
            // Messages display
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 150)
            
            // Message input area
            HStack {
                TextField("Ask about \(title.lowercased())...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.teal)
                }
                .padding(.trailing)
                .disabled(newMessage.isEmpty)
            }
            .padding(.vertical, 4)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.1), radius: 8, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(colorScheme == .dark ? Color.teal.opacity(0.5) : Color.teal.opacity(0.4), lineWidth: 2)
        )
        .padding(.horizontal)
    }
}

// MARK: - Header View
struct HeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Image(systemName: "brain.head.profile")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.teal)
                .padding()
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color.teal.opacity(0.2) : Color.teal.opacity(0.1))
                )
                .frame(width: 80, height: 80)
            
            Text("AI Sage")
                .font(.title3)
                .bold()
                .foregroundColor(.teal)
            
            Text("Ask me anything about trading!")
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
                .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - AI Sage View
// Main view for the AI-powered trading assistant
struct AISageView: View {
    @Environment(\.colorScheme) var colorScheme
    // State management for chat
    @State private var technicalMessages: [ChatMessage] = [] // Technical Analysis chat history
    @State private var psychologyMessages: [ChatMessage] = [] // Trading Psychology chat history
    @State private var technicalNewMessage = "" // Current message input for Technical Analysis
    @State private var psychologyNewMessage = "" // Current message input for Trading Psychology
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
                HeaderView()
                    .padding(.top, 8)
                
                ChatBoxView(
                    title: "Technical Analysis and Forex",
                    messages: technicalMessages,
                    newMessage: $technicalNewMessage,
                    onSend: sendTechnicalMessage
                )
                
                ChatBoxView(
                    title: "Trading Psychology",
                    messages: psychologyMessages,
                    newMessage: $psychologyNewMessage,
                    onSend: sendPsychologyMessage
                )
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
    
    // MARK: - Message Handling
    // Function to handle sending technical analysis messages
    private func sendTechnicalMessage() {
        guard !technicalNewMessage.isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(
            content: technicalNewMessage,
            isUser: true,
            timestamp: Date()
        )
        technicalMessages.append(userMessage)
        
        // Clear input field
        let sentMessage = technicalNewMessage
        technicalNewMessage = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = ChatMessage(
                content: "I'm analyzing your technical analysis question. This is a placeholder response.",
                isUser: false,
                timestamp: Date()
            )
            technicalMessages.append(aiResponse)
        }
    }
    
    // Function to handle sending trading psychology messages
    private func sendPsychologyMessage() {
        guard !psychologyNewMessage.isEmpty else { return }
        
        // Create and add user message
        let userMessage = ChatMessage(
            content: psychologyNewMessage,
            isUser: true,
            timestamp: Date()
        )
        psychologyMessages.append(userMessage)
        
        // Clear input field
        let sentMessage = psychologyNewMessage
        psychologyNewMessage = ""
        
        // Simulate AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = ChatMessage(
                content: "I'm analyzing your trading psychology question. This is a placeholder response.",
                isUser: false,
                timestamp: Date()
            )
            psychologyMessages.append(aiResponse)
        }
    }
}

// MARK: - Preview
#Preview {
    AISageView()
        .preferredColorScheme(.dark)
} 