//
//  TradingStrategiesView.swift
//  ForexAISage
//
//  Created by Bill Skrzypczak on 5/26/25.
//

import SwiftUI

struct TradingStrategy: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let timeframe: String
    let riskLevel: String
    let icon: String
    let imageName: String
    let howToSummary: String
}

struct HowToView: View {
    let strategy: TradingStrategy
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(strategy.howToSummary)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                )
            
            Spacer()
        }
        .padding()
        .navigationTitle("How To \(strategy.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct StrategyVisualizationView: View {
    let strategy: TradingStrategy
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    private func getStrategyImage() -> some View {
        switch strategy.name {
        case "Trend Following":
            return AnyView(
                VStack(spacing: 0) {
                    // Uptrend
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 150))
                        path.addLine(to: CGPoint(x: 100, y: 100))
                        path.addLine(to: CGPoint(x: 150, y: 120))
                        path.addLine(to: CGPoint(x: 200, y: 80))
                        path.addLine(to: CGPoint(x: 250, y: 100))
                    }
                    .stroke(Color.green, lineWidth: 3)
                    
                    // Moving Average
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 130))
                        path.addLine(to: CGPoint(x: 100, y: 110))
                        path.addLine(to: CGPoint(x: 150, y: 100))
                        path.addLine(to: CGPoint(x: 200, y: 90))
                        path.addLine(to: CGPoint(x: 250, y: 80))
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "Breakout Trading":
            return AnyView(
                VStack(spacing: 0) {
                    // Consolidation
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 100))
                        path.addLine(to: CGPoint(x: 100, y: 120))
                        path.addLine(to: CGPoint(x: 150, y: 110))
                        path.addLine(to: CGPoint(x: 200, y: 130))
                        path.addLine(to: CGPoint(x: 250, y: 120))
                    }
                    .stroke(Color.gray, lineWidth: 2)
                    
                    // Breakout
                    Path { path in
                        path.move(to: CGPoint(x: 250, y: 120))
                        path.addLine(to: CGPoint(x: 300, y: 80))
                    }
                    .stroke(Color.green, lineWidth: 3)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "Range Trading":
            return AnyView(
                VStack(spacing: 0) {
                    // Upper Range
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 80))
                        path.addLine(to: CGPoint(x: 300, y: 80))
                    }
                    .stroke(Color.red, lineWidth: 2)
                    
                    // Lower Range
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 120))
                        path.addLine(to: CGPoint(x: 300, y: 120))
                    }
                    .stroke(Color.green, lineWidth: 2)
                    
                    // Price Movement
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 100))
                        path.addLine(to: CGPoint(x: 100, y: 90))
                        path.addLine(to: CGPoint(x: 150, y: 110))
                        path.addLine(to: CGPoint(x: 200, y: 85))
                        path.addLine(to: CGPoint(x: 250, y: 115))
                        path.addLine(to: CGPoint(x: 300, y: 100))
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "Scalping":
            return AnyView(
                VStack(spacing: 0) {
                    // Quick Trades
                    ForEach(0..<5) { i in
                        Path { path in
                            let x = 50 + Double(i) * 60
                            path.move(to: CGPoint(x: x, y: 100))
                            path.addLine(to: CGPoint(x: x + 20, y: 80))
                            path.addLine(to: CGPoint(x: x + 40, y: 100))
                        }
                        .stroke(Color.green, lineWidth: 2)
                    }
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "Position Trading":
            return AnyView(
                VStack(spacing: 0) {
                    // Long-term Trend
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 150))
                        path.addCurve(
                            to: CGPoint(x: 300, y: 50),
                            control1: CGPoint(x: 100, y: 100),
                            control2: CGPoint(x: 200, y: 50)
                        )
                    }
                    .stroke(Color.blue, lineWidth: 3)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "Mean Reversion":
            return AnyView(
                VStack(spacing: 0) {
                    // Mean Line
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 100))
                        path.addLine(to: CGPoint(x: 300, y: 100))
                    }
                    .stroke(Color.gray, lineWidth: 2)
                    
                    // Price Movement
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 100))
                        path.addCurve(
                            to: CGPoint(x: 300, y: 100),
                            control1: CGPoint(x: 100, y: 50),
                            control2: CGPoint(x: 200, y: 150)
                        )
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        case "News Trading":
            return AnyView(
                VStack(spacing: 0) {
                    // News Impact
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: 100))
                        path.addLine(to: CGPoint(x: 150, y: 100))
                        path.addLine(to: CGPoint(x: 160, y: 50))
                        path.addLine(to: CGPoint(x: 170, y: 150))
                        path.addLine(to: CGPoint(x: 300, y: 100))
                    }
                    .stroke(Color.orange, lineWidth: 3)
                }
                .frame(width: 300, height: 200)
                .background(Color.black.opacity(0.1))
            )
            
        default:
            return AnyView(
                Text("No visualization available")
                    .foregroundColor(.gray)
            )
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            getStrategyImage()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                )
            
            Text(strategy.name)
                .font(.title2)
                .bold()
                .foregroundColor(colorScheme == .dark ? .white : .black)
            
            Text("Strategy Visualization")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationTitle("Strategy View")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}

struct TradingStrategiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedStrategy: TradingStrategy?
    @State private var showingHowTo = false
    @State private var selectedStrategyForHowTo: TradingStrategy?
    
    private let strategies = [
        TradingStrategy(
            name: "Trend Following",
            description: "Follow the market trend using moving averages and momentum indicators",
            timeframe: "Medium to Long-term",
            riskLevel: "Medium",
            icon: "chart.line.uptrend.xyaxis",
            imageName: "trend_following",
            howToSummary: "Use 50 and 200 EMA to identify the trend direction. Enter long when price is above both EMAs, short when below. Use RSI to confirm trend strength. Set stop loss below recent swing low/high and aim for 2:1 or 3:1 risk-reward ratio."
        ),
        TradingStrategy(
            name: "Breakout Trading",
            description: "Trade breakouts from consolidation patterns with volume confirmation",
            timeframe: "Short to Medium-term",
            riskLevel: "High",
            icon: "arrow.up.right.and.arrow.down.left",
            imageName: "breakout_trading",
            howToSummary: "Identify consolidation patterns like triangles or rectangles. Wait for price to break with increased volume. Enter in the breakout direction. Set stop loss below/above the breakout level and target the next significant support/resistance level."
        ),
        TradingStrategy(
            name: "Range Trading",
            description: "Trading within defined support and resistance levels",
            timeframe: "Short-term",
            riskLevel: "Low to Medium",
            icon: "arrow.left.and.right",
            imageName: "range_trading",
            howToSummary: "Find clear support and resistance levels. Buy at support when RSI is oversold, sell at resistance when RSI is overbought. Use tight stop losses within the range. Take profit at the opposite boundary and exit if the range breaks."
        ),
        TradingStrategy(
            name: "Scalping",
            description: "Quick trades with tight stops for small but frequent profits",
            timeframe: "Very Short-term",
            riskLevel: "High",
            icon: "bolt.fill",
            imageName: "scalping",
            howToSummary: "Use 1 or 5-minute charts on high liquidity pairs. Enter on small pullbacks in the trend. Use tight 5-10 pip stop losses. Take quick 10-15 pip profits. Monitor spread costs and exit quickly if the trade moves against you."
        ),
        TradingStrategy(
            name: "Position Trading",
            description: "Long-term trading based on fundamental analysis and market trends",
            timeframe: "Long-term",
            riskLevel: "Low",
            icon: "chart.bar.fill",
            imageName: "position_trading",
            howToSummary: "Analyze fundamental economic factors and long-term market trends. Use weekly/monthly charts for entries. Set wider stops to account for volatility. Scale in/out of positions and hold for weeks to months."
        ),
        TradingStrategy(
            name: "Mean Reversion",
            description: "Trade price reversions to the mean using Bollinger Bands",
            timeframe: "Medium to Long-term",
            riskLevel: "Medium",
            icon: "arrow.left.and.right",
            imageName: "mean_reversion",
            howToSummary: "Use Bollinger Bands (20 period, 2 SD) to identify overbought/oversold conditions. Buy at the lower band, sell at the upper band. Confirm with RSI. Set stops beyond the bands and take profit at the middle band."
        ),
        TradingStrategy(
            name: "News Trading",
            description: "Trade based on economic news releases and market reactions",
            timeframe: "Medium to Long-term",
            riskLevel: "Medium",
            icon: "newspaper.fill",
            imageName: "news_trading",
            howToSummary: "Monitor the economic calendar for high-impact news. Prepare orders before the release. Enter on the initial spike. Use wider stops to account for volatility. Exit before the next news event to avoid whipsaws."
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
                            
                            Text("Risk: \(strategy.riskLevel)")
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
                        
                        // How To Button
                        NavigationLink(destination: HowToView(strategy: strategy)) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                Text("How To")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                        }
                        .padding(.top, 8)
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

