//
//  ContentView.swift
//  ForexAISage
//
//  Created by Bill Skrzypczak on 5/26/25.
//

import SwiftUI

// MARK: - Main Content View
// This is the root view of the application that contains the main navigation and tab structure
struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        // Main vertical stack containing the app title and tab navigation
        VStack(spacing: 0) {
            // App title header with gradient background
            HStack {
                Text("ForexAISage")
                    .font(.system(size: 34, weight: .bold))
                
                Spacer()
                
                // Dark mode toggle button
                Button(action: {
                    isDarkMode.toggle()
                }) {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isDarkMode ? .yellow : .blue)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                        )
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        colorScheme == .dark ? Color.teal.opacity(0.3) : Color.teal.opacity(0.2),
                        colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.2)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            
            // Tab navigation containing the three main sections of the app
            TabView {
                // Chart section for viewing forex pair charts
                ChartTabView()
                    .tabItem {
                        Label("Chart", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    .font(.title3)
                
                // Watchlist section for managing forex pairs
                WatchlistView()
                    .tabItem {
                        Label("Watchlist", systemImage: "list.bullet")
                    }
                    .font(.title3)
                
                // AI Sage section for AI-powered insights
                AISageView()
                    .tabItem {
                        Label("AI Sage", systemImage: "brain")
                    }
                    .font(.title3)
            }
            .accentColor(.teal)
        }
        .navigationTitle("ForexAISage")
        .navigationBarTitleDisplayMode(.large)
        .background(colorScheme == .dark ? Color.black : Color.white)
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Chart Tab View
// This view handles the display and interaction with forex pair charts
struct ChartTabView: View {
    @Environment(\.colorScheme) var colorScheme
    // State management for forex pairs and selection
    @State private var pairs = [
        ForexPair(symbol: "EUR/USD", name: "Euro / US Dollar", description: "The most traded currency pair in the world"),
        ForexPair(symbol: "GBP/USD", name: "British Pound / US Dollar", description: "Known as 'Cable' in forex trading"),
        ForexPair(symbol: "USD/JPY", name: "US Dollar / Japanese Yen", description: "Major Asian currency pair"),
        ForexPair(symbol: "USD/CHF", name: "US Dollar / Swiss Franc", description: "Known as 'Swissy' in forex trading"),
        ForexPair(symbol: "AUD/USD", name: "Australian Dollar / US Dollar", description: "Popular commodity currency pair")
    ]
    @State private var selectedPair = ForexPair(symbol: "EUR/USD", name: "Euro / US Dollar", description: "The most traded currency pair in the world")
    @State private var searchText = ""
    
    // Computed property that filters pairs based on search input
    var filteredPairs: [ForexPair] {
        if searchText.isEmpty {
            return pairs
        }
        return pairs.filter { pair in
            pair.symbol.localizedCaseInsensitiveContains(searchText) ||
            pair.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Dropdown menu for selecting forex pairs
                    Menu {
                        ForEach(filteredPairs) { pair in
                            Button(action: {
                                selectedPair = pair
                            }) {
                                Text(pair.name)
                            }
                        }
                    } label: {
                        // Custom styled dropdown button with pair name and chevron
                        HStack {
                            Text(selectedPair.name)
                                .font(.title3)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding()
                    .zIndex(1) // Ensure menu stays on top
                    
                    // Chart view component for displaying the selected pair's data
                    ChartView(pair: selectedPair.symbol)
                        .id(selectedPair.symbol) // Force view refresh when pair changes
                }
            }
            .navigationTitle("Daily Chart")
            .navigationBarTitleDisplayMode(.inline)
            .background(colorScheme == .dark ? Color.black : Color.white)
        }
    }
}

// MARK: - Preview
// SwiftUI preview provider for development
#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
