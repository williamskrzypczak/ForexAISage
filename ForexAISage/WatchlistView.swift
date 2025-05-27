import SwiftUI

// MARK: - Watchlist View
// Main view for managing and displaying the user's forex pair watchlist
struct WatchlistView: View {
    // State management for the watchlist
    @State private var pairs = ForexPair.commonPairs // List of forex pairs in watchlist
    @State private var searchText = "" // Search query for filtering pairs
    @State private var showingAddPair = false // Controls the add pair sheet presentation
    
    // Create an instance of the forex data service
    @StateObject private var forexService = ForexDataService()
    
    // Computed property that filters pairs based on search text
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
            List {
                // Display each forex pair in the watchlist
                ForEach(filteredPairs) { pair in
                    HStack {
                        // Pair information display
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pair.symbol)
                                .font(.title3)
                                .bold()
                            Text(pair.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Current price display with real-time updates
                        if let currentPrice = forexService.currentPrice {
                            Text(String(format: "%.4f", currentPrice))
                                .font(.title3)
                        } else {
                            Text("Loading...")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.teal.opacity(0.1))
                    .cornerRadius(8)
                    .onAppear {
                        forexService.fetchCurrentPrice(for: pair.symbol)
                    }
                }
                .onDelete(perform: deletePairs) // Enable swipe-to-delete functionality
            }
            .searchable(text: $searchText, prompt: "Search pairs")
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                // Add pair button in navigation bar
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddPair = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                }
            }
            // Present add pair sheet when showingAddPair is true
            .sheet(isPresented: $showingAddPair) {
                AddPairView(pairs: $pairs)
            }
        }
    }
    
    // Function to handle pair deletion
    private func deletePairs(at offsets: IndexSet) {
        pairs.remove(atOffsets: offsets)
    }
}

// MARK: - Add Pair View
// Sheet view for adding new forex pairs to the watchlist
struct AddPairView: View {
    @Environment(\.dismiss) var dismiss // Environment value for dismissing the sheet
    @Binding var pairs: [ForexPair] // Binding to the parent's pairs array
    @State private var selectedPair: ForexPair? // Currently selected pair
    
    // Computed property that filters out already added pairs
    var availablePairs: [ForexPair] {
        ForexPair.commonPairs.filter { pair in
            !pairs.contains { $0.symbol == pair.symbol }
        }
    }
    
    var body: some View {
        NavigationView {
            List(availablePairs) { pair in
                // Pair selection button
                Button(action: {
                    selectedPair = pair
                }) {
                    HStack {
                        // Pair information display
                        VStack(alignment: .leading, spacing: 4) {
                            Text(pair.symbol)
                                .font(.title3)
                                .bold()
                            Text(pair.name)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        // Selection indicator
                        if selectedPair?.symbol == pair.symbol {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Add Pair")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Add button (disabled if no pair is selected)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if let pair = selectedPair {
                            pairs.append(pair)
                            dismiss()
                        }
                    }
                    .disabled(selectedPair == nil)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WatchlistView()
} 