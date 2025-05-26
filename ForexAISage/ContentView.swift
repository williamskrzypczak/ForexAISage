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
    var body: some View {
        // Main vertical stack containing the app title and tab navigation
        VStack(spacing: 0) {
            // App title header with gradient background
            Text("ForexAISage")
                .font(.system(size: 34, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.2)]),
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
    }
}

// MARK: - Chart Tab View
// This view handles the display and interaction with forex pair charts
struct ChartTabView: View {
    // State management for forex pairs and selection
    @State private var pairs = ForexPair.commonPairs
    @State private var selectedPair = ForexPair.commonPairs[0]
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
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                
                // Chart view component for displaying the selected pair's data
                ChartView(pair: selectedPair.symbol)
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Preview
// SwiftUI preview provider for development
#Preview {
    ContentView()
}
