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

// MARK: - Message Input View
struct MessageInputView: View {
    @Binding var message: String
    let placeholder: String
    let onSend: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack {
            TextField("", text: $message)
                .placeholder(when: message.isEmpty) {
                    Text(placeholder)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .font(.subheadline)
                        .padding(.leading, 4)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
                        .shadow(color: .teal.opacity(0.2), radius: 2, x: 0, y: 1)
                )
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.teal)
            }
            .padding(.trailing)
            .disabled(message.isEmpty)
        }
        .padding(.vertical, 4)
        .background(colorScheme == .dark ? Color.black : Color.white)
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
            
            // Prompt Text
            Text("Ask me about \(title.lowercased())!")
                .font(.subheadline)
                .foregroundColor(.teal)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorScheme == .dark ? Color.teal.opacity(0.15) : Color.teal.opacity(0.1))
                )
                .padding(.horizontal)
                .padding(.top, 8)
            
            // Messages
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        ChatBubble(message: message)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 150)
            
            // Input
            MessageInputView(
                message: $newMessage,
                placeholder: "Type your question here...",
                onSend: onSend
            )
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
    @State private var selectedInsight: String?
    
    private let insights = [
        "Market Analysis": "AI-powered analysis of current market trends and potential opportunities.",
        "Risk Assessment": "Real-time risk evaluation and management recommendations.",
        "Trade Signals": "Advanced pattern recognition and trading signal generation.",
        "News Impact": "Analysis of news events and their potential market impact.",
        "Strategy Optimization": "Continuous learning and strategy improvement based on market data."
    ]
    
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
    
    private func getIcon(for insight: String) -> String {
        switch insight {
        case "Market Analysis": return "chart.line.uptrend.xyaxis"
        case "Risk Assessment": return "exclamationmark.shield.fill"
        case "Trade Signals": return "bell.badge.fill"
        case "News Impact": return "newspaper.fill"
        case "Strategy Optimization": return "gearshape.2.fill"
        default: return "questionmark.circle.fill"
        }
    }
}

struct InsightDetailView: View {
    let insight: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: getIcon(for: insight))
                            .font(.largeTitle)
                            .foregroundColor(.teal)
                        Text(insight)
                            .font(.title)
                            .bold()
                    }
                    .padding()
                    
                    // Content
                    Text(getDetailContent(for: insight))
                        .font(.body)
                        .padding()
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getIcon(for insight: String) -> String {
        switch insight {
        case "Market Analysis": return "chart.line.uptrend.xyaxis"
        case "Risk Assessment": return "exclamationmark.shield.fill"
        case "Trade Signals": return "bell.badge.fill"
        case "News Impact": return "newspaper.fill"
        case "Strategy Optimization": return "gearshape.2.fill"
        default: return "questionmark.circle.fill"
        }
    }
    
    private func getDetailContent(for insight: String) -> String {
        switch insight {
        case "Market Analysis":
            return "Our AI analyzes market trends, patterns, and indicators to provide comprehensive market insights. It processes vast amounts of data to identify potential trading opportunities and market movements."
        case "Risk Assessment":
            return "Advanced risk evaluation algorithms help you understand and manage trading risks. The system continuously monitors market conditions and provides real-time risk management recommendations."
        case "Trade Signals":
            return "Get precise trading signals based on multiple technical indicators and market conditions. Our AI identifies high-probability trading opportunities and generates actionable signals."
        case "News Impact":
            return "Stay informed about how news events affect the market. Our AI analyzes news sentiment and its potential impact on currency pairs, helping you make informed trading decisions."
        case "Strategy Optimization":
            return "Continuously improve your trading strategies with AI-powered optimization. The system learns from market data and your trading history to suggest strategy improvements."
        default:
            return "No detailed information available."
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
}

// MARK: - Preview
#Preview {
    AISageView()
        .preferredColorScheme(.dark)
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
        
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
} 