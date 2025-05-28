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
}

struct TradingStrategiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedStrategy: TradingStrategy?
    
    private let strategies = [
        TradingStrategy(
            name: "Trend Following",
            description: "A strategy that follows the market trend, buying on uptrends and selling on downtrends.",
            timeframe: "Medium to Long-term",
            riskLevel: "Medium",
            icon: "arrow.up.right",
            imageName: "trend_following"
        ),
        TradingStrategy(
            name: "Breakout Trading",
            description: "Trading based on price breaking through support or resistance levels.",
            timeframe: "Short to Medium-term",
            riskLevel: "High",
            icon: "arrow.up.forward",
            imageName: "breakout_trading"
        ),
        TradingStrategy(
            name: "Range Trading",
            description: "Trading within defined support and resistance levels.",
            timeframe: "Short-term",
            riskLevel: "Low to Medium",
            icon: "arrow.left.and.right",
            imageName: "range_trading"
        ),
        TradingStrategy(
            name: "Scalping",
            description: "Making multiple trades to capture small price movements.",
            timeframe: "Very Short-term",
            riskLevel: "High",
            icon: "chart.line.uptrend.xyaxis",
            imageName: "scalping"
        ),
        TradingStrategy(
            name: "Position Trading",
            description: "Long-term trading based on fundamental analysis and market trends.",
            timeframe: "Long-term",
            riskLevel: "Low",
            icon: "chart.bar.fill",
            imageName: "position_trading"
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
                        
                        // Strategy Image
                        if selectedStrategy?.id == strategy.id {
                            Image(systemName: getImageName(for: strategy))
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.teal)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.teal.opacity(0.1))
                                )
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding(.top, 8)
                        }
                        
                        // Show/Hide Image Button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if selectedStrategy?.id == strategy.id {
                                    selectedStrategy = nil
                                } else {
                                    selectedStrategy = strategy
                                }
                            }
                        }) {
                            HStack {
                                Image(systemName: selectedStrategy?.id == strategy.id ? "chevron.up" : "photo")
                                Text(selectedStrategy?.id == strategy.id ? "Hide Image" : "Show Image")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
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
    
    private func getImageName(for strategy: TradingStrategy) -> String {
        switch strategy.name {
        case "Trend Following":
            return "chart.line.uptrend.xyaxis"
        case "Breakout Trading":
            return "arrow.up.forward"
        case "Range Trading":
            return "arrow.left.and.right"
        case "Scalping":
            return "chart.xyaxis.line"
        case "Position Trading":
            return "chart.bar.fill"
        default:
            return "chart.line.uptrend.xyaxis"
        }
    }
}

#Preview {
    TradingStrategiesView()
        .preferredColorScheme(.dark)
}

