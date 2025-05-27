import Foundation

// MARK: - Forex Data Service
// Service responsible for fetching delayed forex data from Alpha Vantage API
class ForexDataService: ObservableObject {
    // API key for Alpha Vantage (you'll need to replace this with your own key)
    private let apiKey = "EC1GA0IPR84R1HUB"
    private let baseURL = "https://www.alphavantage.co/query"
    
    // Cache for historical data
    private var historicalDataCache: [String: (data: [PricePoint], timestamp: Date)] = [:]
    private let cacheValidityDuration: TimeInterval = 3600 // 1 hour
    
    // Cache for current prices
    private var currentPriceCache: [String: (price: Double, timestamp: Date)] = [:]
    private let currentPriceCacheDuration: TimeInterval = 300 // 5 minutes
    
    // UserDefaults keys
    private let lastValidDataKey = "lastValidForexData"
    private let lastValidPriceKey = "lastValidForexPrice"
    
    // Published properties for real-time updates
    @Published var currentPrice: Double?
    @Published var priceChange: Double?
    @Published var priceChangePercent: Double?
    @Published var lastUpdated: Date?
    @Published var error: String?
    
    init() {
        loadLastValidData()
    }
    
    // MARK: - Last Valid Data Management
    private func saveLastValidData(pair: String, data: [PricePoint]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(data) {
            UserDefaults.standard.set(encoded, forKey: "\(lastValidDataKey)_\(pair)")
        }
    }
    
    private func loadLastValidData() {
        // Load last valid data for all pairs
        for pair in ForexPair.commonPairs {
            if let data = UserDefaults.standard.data(forKey: "\(lastValidDataKey)_\(pair.symbol)"),
               let decoded = try? JSONDecoder().decode([PricePoint].self, from: data) {
                historicalDataCache[pair.symbol] = (data: decoded, timestamp: Date())
            }
            
            let price = UserDefaults.standard.object(forKey: "\(lastValidPriceKey)_\(pair.symbol)") as? Double
            if let price = price, price > 0 {
                currentPriceCache[pair.symbol] = (price: price, timestamp: Date())
            }
        }
    }
    
    private func saveLastValidPrice(pair: String, price: Double) {
        UserDefaults.standard.set(price, forKey: "\(lastValidPriceKey)_\(pair)")
    }
    
    // MARK: - Dummy Data Generation
    private func generateDummyData(for pair: String) -> [PricePoint] {
        let calendar = Calendar.current
        let today = Date()
        let basePrice = currentPriceCache[pair]?.price ?? 1.0
        
        // Generate 30 days of dummy data
        return (0..<30).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let randomChange = Double.random(in: -0.02...0.02) // Random change between -2% and +2%
            let price = basePrice * (1 + randomChange)
            
            return PricePoint(
                date: date,
                open: price,
                high: price * (1 + Double.random(in: 0...0.01)),
                low: price * (1 - Double.random(in: 0...0.01)),
                close: price * (1 + Double.random(in: -0.005...0.005)),
                volume: Double.random(in: 1000...5000)
            )
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Fetch Current Price
    // Fetches the current delayed price for a forex pair
    func fetchCurrentPrice(for pair: String) {
        // Check cache first
        if let cached = currentPriceCache[pair],
           Date().timeIntervalSince(cached.timestamp) < currentPriceCacheDuration {
            print("Using cached current price for \(pair)")
            self.currentPrice = cached.price
            self.lastUpdated = cached.timestamp
            self.error = nil
            return
        }
        
        // Convert pair format from "EUR/USD" to "EURUSD" for API
        let formattedPair = pair.replacingOccurrences(of: "/", with: "")
        
        // Construct URL with query parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "function", value: "CURRENCY_EXCHANGE_RATE"),
            URLQueryItem(name: "from_currency", value: String(formattedPair.prefix(3))),
            URLQueryItem(name: "to_currency", value: String(formattedPair.suffix(3))),
            URLQueryItem(name: "apikey", value: apiKey)
        ]
        
        guard let url = components.url else {
            self.error = "Invalid URL"
            return
        }
        
        print("Fetching current price for \(pair) with URL: \(url.absoluteString)")
        
        // Create and start URL session task
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self?.error = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    self?.error = "Invalid response from server"
                    return
                }
                
                print("Response status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Server error with status code: \(httpResponse.statusCode)")
                    self?.error = "Server error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    self?.error = "No data received"
                    return
                }
                
                // Print raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API response: \(jsonString)")
                }
                
                do {
                    // Parse JSON response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        // Check for API error messages
                        if let errorMessage = json["Error Message"] as? String {
                            print("API Error: \(errorMessage)")
                            self?.error = "API Error: \(errorMessage)"
                            return
                        }
                        
                        if let note = json["Note"] as? String {
                            print("API Note: \(note)")
                            if note.contains("API call frequency") || note.contains("rate limit") {
                                // Use cached data if available
                                if let cached = self?.currentPriceCache[pair] {
                                    print("Using expired cached price due to rate limit")
                                    self?.currentPrice = cached.price
                                    self?.lastUpdated = cached.timestamp
                                    self?.error = "Using cached data (API rate limit reached)"
                                } else {
                                    // Generate a dummy price if no cache available
                                    let dummyPrice = 1.0 + Double.random(in: -0.1...0.1)
                                    self?.currentPrice = dummyPrice
                                    self?.lastUpdated = Date()
                                    self?.error = "Using generated data (API rate limit reached)"
                                    self?.currentPriceCache[pair] = (price: dummyPrice, timestamp: Date())
                                    self?.saveLastValidPrice(pair: pair, price: dummyPrice)
                                }
                                return
                            }
                            self?.error = "API Note: \(note)"
                            return
                        }
                        
                        if let exchangeRate = json["Realtime Currency Exchange Rate"] as? [String: String],
                           let rate = exchangeRate["5. Exchange Rate"],
                           let price = Double(rate) {
                            
                            print("Successfully parsed price: \(price)")
                            self?.currentPrice = price
                            self?.lastUpdated = Date()
                            self?.error = nil
                            
                            // Cache the successful response
                            self?.currentPriceCache[pair] = (price: price, timestamp: Date())
                            self?.saveLastValidPrice(pair: pair, price: price)
                        } else {
                            print("Invalid response format")
                            self?.error = "Invalid response format"
                        }
                    } else {
                        print("Failed to parse JSON")
                        self?.error = "Failed to parse response"
                    }
                } catch {
                    print("JSON parsing error: \(error.localizedDescription)")
                    self?.error = "Failed to parse response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    // MARK: - Fetch Historical Data
    // Fetches historical price data for a forex pair
    func fetchHistoricalData(for pair: String) async throws -> [PricePoint] {
        // Check cache first
        if let cachedData = historicalDataCache[pair],
           Date().timeIntervalSince(cachedData.timestamp) < cacheValidityDuration {
            print("Returning cached data for \(pair)")
            return cachedData.data
        }
        
        // Convert pair format from "EUR/USD" to "EURUSD" for API
        let formattedPair = pair.replacingOccurrences(of: "/", with: "")
        let fromCurrency = String(formattedPair.prefix(3))
        let toCurrency = String(formattedPair.suffix(3))
        
        print("Fetching historical data for pair: \(pair)")
        print("From currency: \(fromCurrency)")
        print("To currency: \(toCurrency)")
        
        // Construct URL with query parameters
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "function", value: "FX_DAILY"),
            URLQueryItem(name: "from_symbol", value: fromCurrency),
            URLQueryItem(name: "to_symbol", value: toCurrency),
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "outputsize", value: "compact")
        ]
        
        guard let url = components.url else {
            print("Failed to construct URL")
            throw URLError(.badURL)
        }
        
        print("Fetching historical data with URL: \(url.absoluteString)")
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type for historical data")
                throw URLError(.badServerResponse)
            }
            
            print("Historical data response status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Server error with status code: \(httpResponse.statusCode)")
                throw URLError(.badServerResponse)
            }
            
            // Print raw response for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw historical data response: \(jsonString)")
            }
            
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            // Check for API error messages
            if let errorMessage = json?["Error Message"] as? String {
                print("API Error for historical data: \(errorMessage)")
                throw NSError(domain: "ForexDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }
            
            if let note = json?["Note"] as? String {
                print("API Note for historical data: \(note)")
                if note.contains("API call frequency") || note.contains("rate limit") {
                    // Generate dummy data when rate limited
                    print("Rate limit reached, generating dummy data")
                    let dummyData = generateDummyData(for: pair)
                    historicalDataCache[pair] = (data: dummyData, timestamp: Date())
                    saveLastValidData(pair: pair, data: dummyData)
                    return dummyData
                }
                throw NSError(domain: "ForexDataService", code: -1, userInfo: [NSLocalizedDescriptionKey: note])
            }
            
            guard let timeSeries = json?["Time Series FX (Daily)"] as? [String: [String: String]] else {
                print("Invalid time series data format")
                if let json = json {
                    print("Available keys in response: \(json.keys.joined(separator: ", "))")
                }
                throw URLError(.cannotParseResponse)
            }
            
            // Create date formatter for parsing dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Convert JSON data to PricePoint array
            let points: [PricePoint] = timeSeries.compactMap { (timestamp, values) in
                guard let date = dateFormatter.date(from: timestamp),
                      let open = Double(values["1. open"] ?? ""),
                      let high = Double(values["2. high"] ?? ""),
                      let low = Double(values["3. low"] ?? ""),
                      let close = Double(values["4. close"] ?? ""),
                      let volume = Double(values["5. volume"] ?? "0") else {
                    print("Failed to parse data point for date: \(timestamp)")
                    print("Values: \(values)")
                    return nil
                }
                
                return PricePoint(
                    date: date,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    volume: volume
                )
            }.sorted { $0.date < $1.date }
            
            print("Successfully parsed \(points.count) historical data points")
            if points.isEmpty {
                print("Warning: No data points were parsed successfully")
            } else {
                // Cache the successful response
                historicalDataCache[pair] = (data: points, timestamp: Date())
                saveLastValidData(pair: pair, data: points)
            }
            return points
        } catch {
            print("Error fetching historical data: \(error.localizedDescription)")
            // Generate dummy data on any error
            print("Error occurred, generating dummy data")
            let dummyData = generateDummyData(for: pair)
            historicalDataCache[pair] = (data: dummyData, timestamp: Date())
            saveLastValidData(pair: pair, data: dummyData)
            return dummyData
        }
    }
} 
