import Foundation

// MARK: - Forex Pair Model
// Represents a currency pair in the forex market
// Conforms to Identifiable protocol for use in SwiftUI lists and ForEach
struct ForexPair: Identifiable {
    // Unique identifier for each forex pair
    let id = UUID()
    // Trading symbol (e.g., "EUR/USD")
    let symbol: String
    // Full name of the currency pair
    let name: String
    // Description of the currency pair and its common nickname
    let description: String
    // Tracks whether the pair is in user's favorites
    var isFavorite: Bool = false
    
    // MARK: - Common Forex Pairs
    // Predefined list of commonly traded forex pairs with their details
    static let commonPairs: [ForexPair] = [
        ForexPair(symbol: "EUR/USD", name: "Euro/US Dollar", description: "The most traded currency pair"),
        ForexPair(symbol: "GBP/USD", name: "British Pound/US Dollar", description: "Known as 'Cable'"),
        ForexPair(symbol: "USD/JPY", name: "US Dollar/Japanese Yen", description: "Known as 'Ninja'"),
        ForexPair(symbol: "USD/CHF", name: "US Dollar/Swiss Franc", description: "Known as 'Swissy'"),
        ForexPair(symbol: "AUD/USD", name: "Australian Dollar/US Dollar", description: "Known as 'Aussie'"),
        ForexPair(symbol: "USD/CAD", name: "US Dollar/Canadian Dollar", description: "Known as 'Loonie'"),
        ForexPair(symbol: "NZD/USD", name: "New Zealand Dollar/US Dollar", description: "Known as 'Kiwi'"),
        ForexPair(symbol: "EUR/GBP", name: "Euro/British Pound", description: "Known as 'Chunnel'"),
        ForexPair(symbol: "EUR/JPY", name: "Euro/Japanese Yen", description: "Popular cross pair"),
        ForexPair(symbol: "GBP/JPY", name: "British Pound/Japanese Yen", description: "Known as 'Dragon'")
    ]
} 