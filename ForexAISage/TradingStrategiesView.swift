//
//  TradingStrategiesView.swift
//  ForexAISage
//
//  Created by Bill Skrzypczak on 5/26/25.
//

import SwiftUI
import WebKit

// MARK: - YouTube Video Player
struct YouTubePlayer: UIViewRepresentable {
    let videoID: String
    @Binding var isLoading: Bool
    @Binding var error: String?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)?playsinline=1") else {
            error = "Invalid video URL"
            return
        }
        isLoading = true
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: YouTubePlayer
        
        init(_ parent: YouTubePlayer) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.error = error.localizedDescription
        }
    }
}

struct TradingStrategy: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let timeframe: String
    let riskLevel: String
    let icon: String
    let videoID: String
    let videoTitle: String
    let channelName: String
}

struct TradingStrategiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedStrategy: TradingStrategy?
    @State private var isLoading = false
    @State private var error: String?
    
    let strategies = [
        TradingStrategy(
            name: "Trend Following",
            description: "A strategy that follows the market trend, buying on uptrends and selling on downtrends.",
            timeframe: "Medium to Long-term",
            riskLevel: "Medium",
            icon: "arrow.up.right",
            videoID: "dF3JQJjX7YE",
            videoTitle: "How to Trade Trends - The Complete Guide",
            channelName: "The Trading Channel"
        ),
        TradingStrategy(
            name: "Breakout Trading",
            description: "Trading based on price breaking through support or resistance levels.",
            timeframe: "Short to Medium-term",
            riskLevel: "High",
            icon: "arrow.up.forward",
            videoID: "YwqXxGQwXxY",
            videoTitle: "Breakout Trading Strategy - Complete Guide",
            channelName: "Trading 212"
        ),
        TradingStrategy(
            name: "Range Trading",
            description: "Trading within defined support and resistance levels.",
            timeframe: "Short-term",
            riskLevel: "Low to Medium",
            icon: "arrow.left.and.right",
            videoID: "XxXxXxXxXxX",
            videoTitle: "Range Trading Strategy - Complete Guide",
            channelName: "ForexSignals TV"
        ),
        TradingStrategy(
            name: "Scalping",
            description: "Making multiple trades to capture small price movements.",
            timeframe: "Very Short-term",
            riskLevel: "High",
            icon: "chart.line.uptrend.xyaxis",
            videoID: "XxXxXxXxXxX",
            videoTitle: "Scalping Strategy - Complete Guide",
            channelName: "ForexSignals TV"
        ),
        TradingStrategy(
            name: "Position Trading",
            description: "Long-term trading based on fundamental analysis and market trends.",
            timeframe: "Long-term",
            riskLevel: "Low",
            icon: "chart.bar.fill",
            videoID: "XxXxXxXxXxX",
            videoTitle: "Position Trading Strategy - Complete Guide",
            channelName: "ForexSignals TV"
        )
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(strategies) { strategy in
                    VStack(alignment: .leading, spacing: 8) {
                        // Strategy Header
                        HStack {
                            Image(systemName: strategy.icon)
                                .font(.title2)
                                .foregroundColor(.teal)
                                .frame(width: 30)
                            
                            Text(strategy.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text(strategy.riskLevel)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(riskLevelColor(strategy.riskLevel))
                                )
                                .foregroundColor(.white)
                        }
                        
                        // Description
                        Text(strategy.description)
                            .font(.subheadline)
                            .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
                        
                        // Timeframe
                        HStack {
                            Label(strategy.timeframe, systemImage: "clock")
                                .font(.caption)
                                .foregroundColor(.teal)
                        }
                        
                        // Video Player
                        if selectedStrategy?.id == strategy.id {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(strategy.videoTitle)
                                    .font(.subheadline)
                                    .bold()
                                
                                Text("by \(strategy.channelName)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                if isLoading {
                                    ProgressView()
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                } else if let error = error {
                                    Text("Error loading video: \(error)")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding()
                                } else {
                                    YouTubePlayer(
                                        videoID: strategy.videoID,
                                        isLoading: $isLoading,
                                        error: $error
                                    )
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top, 8)
                        }
                        
                        // Watch Video Button
                        Button(action: {
                            withAnimation {
                                if selectedStrategy?.id == strategy.id {
                                    selectedStrategy = nil
                                    error = nil
                                } else {
                                    selectedStrategy = strategy
                                    error = nil
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedStrategy?.id == strategy.id ? "chevron.up" : "play.fill")
                                Text(selectedStrategy?.id == strategy.id ? "Hide Video" : "Watch Video")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.yellow, .pink]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: .yellow.opacity(0.5), radius: 6, x: 0, y: 2)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Trading Strategies")
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
    
    private func riskLevelColor(_ level: String) -> Color {
        switch level {
        case "Low":
            return .green
        case "Medium":
            return .orange
        case "High":
            return .red
        default:
            return .gray
        }
    }
}

#Preview {
    TradingStrategiesView()
        .preferredColorScheme(.dark)
} 