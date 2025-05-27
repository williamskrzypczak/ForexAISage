import SwiftUI
import Charts

// MARK: - Price Point Model
// Represents a single data point in the price chart
// Contains OHLC (Open, High, Low, Close) data and volume
struct PricePoint: Identifiable, Codable {
    let id: UUID
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
    
    // Coding keys for custom encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id, date, open, high, low, close, volume
    }
    
    // Custom encoding to handle UUID
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(open, forKey: .open)
        try container.encode(high, forKey: .high)
        try container.encode(low, forKey: .low)
        try container.encode(close, forKey: .close)
        try container.encode(volume, forKey: .volume)
    }
    
    // Custom decoding to handle UUID
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idString = try container.decode(String.self, forKey: .id)
        self.id = UUID(uuidString: idString) ?? UUID()
        self.date = try container.decode(Date.self, forKey: .date)
        self.open = try container.decode(Double.self, forKey: .open)
        self.high = try container.decode(Double.self, forKey: .high)
        self.low = try container.decode(Double.self, forKey: .low)
        self.close = try container.decode(Double.self, forKey: .close)
        self.volume = try container.decode(Double.self, forKey: .volume)
    }
    
    // Regular initializer
    init(date: Date, open: Double, high: Double, low: Double, close: Double, volume: Double) {
        self.id = UUID()
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
}

// MARK: - Chart View
// Main view for displaying forex price charts with multiple chart types
struct ChartView: View {
    // The currency pair being displayed
    let pair: String
    
    // State variables for chart configuration
    @State private var selectedChartType = 0
    @State private var priceData: [PricePoint] = []
    @State private var isLoading = false
    @State private var error: String?
    
    // Create an instance of the forex data service
    @StateObject private var forexService = ForexDataService()
    
    let chartTypes = ["Line", "Candlestick", "Area"]
    
    // MARK: - Load Data
    private func loadData() {
        isLoading = true
        error = nil
        
        Task {
            do {
                let data = try await forexService.fetchHistoricalData(for: pair)
                await MainActor.run {
                    priceData = data
                    isLoading = false
                }
            } catch let error as NSError {
                await MainActor.run {
                    self.error = error.localizedDescription
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to load data: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Chart Calculations
    // Calculate min and max values for Y-axis scaling with padding
    var priceRange: (min: Double, max: Double) {
        let allPrices = priceData.flatMap { [$0.low, $0.open, $0.close] }
        let minPrice = allPrices.min() ?? 0
        let maxPrice = allPrices.max() ?? 0
        let paddingAmount = (maxPrice - minPrice) * 0.1 // Add 10% padding
        return (minPrice - paddingAmount, maxPrice + paddingAmount)
    }
    
    // Chart layout constants
    private static let chartHorizontalPadding: CGFloat = 20
    
    // Calculate dynamic candle width based on available space
    var candleWidth: CGFloat {
        let maxAllowedWidth: CGFloat = 20 // Maximum width for a candle
        let minAllowedWidth: CGFloat = 2 // Minimum width
        let spacing: CGFloat = 2 // Spacing between candles
        let totalWidth = 300 - (Self.chartHorizontalPadding * 2) // Total available width for candles
        
        let calculatedWidth = (totalWidth / CGFloat(priceData.count)) - spacing
        return max(minAllowedWidth, min(maxAllowedWidth, calculatedWidth))
    }
    
    // MARK: - View Body
    var body: some View {
        VStack(spacing: 12) {
            // Delay Notice
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.orange)
                Text("Data delayed by 15 minutes")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
            .padding(.horizontal)
            .padding(.vertical, 4)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
            
            // Chart Type Selection
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(0..<chartTypes.count, id: \.self) { index in
                    Text(chartTypes[index])
                        .font(.subheadline)
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Chart and Price Information Display
            VStack(spacing: 4) {
                // Price Information Header
                HStack {
                    Text(pair)
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    if let currentPrice = forexService.currentPrice {
                        Text(String(format: "%.4f", currentPrice))
                            .font(.headline)
                            .bold()
                    }
                    
                    if let change = forexService.priceChangePercent {
                        Text(String(format: "%.2f%%", change))
                            .font(.subheadline)
                            .foregroundColor(change >= 0 ? .green : .red)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 4)
                
                if isLoading {
                    ProgressView()
                        .frame(height: 250)
                } else if let error = error {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 30))
                            .foregroundColor(.red)
                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        Button("Retry") {
                            loadData()
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                    .frame(height: 250)
                } else if priceData.isEmpty {
                    Text("No data available")
                        .foregroundColor(.gray)
                        .frame(height: 250)
                } else {
                    // Main Chart Display
                    Chart(priceData) { point in
                        if selectedChartType == 0 {
                            // Line Chart Implementation
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Price", point.close)
                            )
                            .foregroundStyle(Color.blue)
                        } else if selectedChartType == 1 {
                            // Candlestick Chart Implementation
                            // Bar represents the body of the candle
                            BarMark(
                                x: .value("Date", point.date),
                                yStart: .value("Open", point.open),
                                yEnd: .value("Close", point.close),
                                width: .fixed(candleWidth)
                            )
                            .foregroundStyle(point.close >= point.open ? Color.green : Color.red)

                            // Rule represents the wicks of the candle
                            RuleMark(
                                x: .value("Date", point.date),
                                yStart: .value("Low", point.low),
                                yEnd: .value("High", point.high)
                            )
                            .foregroundStyle(point.close >= point.open ? Color.green : Color.red)
                        } else {
                            // Area Chart Implementation
                            AreaMark(
                                x: .value("Date", point.date),
                                yStart: .value("Price", priceRange.min),
                                yEnd: .value("Price", point.close)
                            )
                            .foregroundStyle(Color.blue.gradient)
                        }
                    }
                    .chartYScale(domain: priceRange.min...priceRange.max)
                    .chartXScale(domain: priceData.first!.date...priceData.last!.date)
                    .frame(height: 250)
                }
                
                // OHLC Information for Candlestick Chart
                if selectedChartType == 1, let lastPrice = priceData.last {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(format: "O: %.4f", lastPrice.open))
                            Text(String(format: "H: %.4f", lastPrice.high))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "L: %.4f", lastPrice.low))
                            Text(String(format: "C: %.4f", lastPrice.close))
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                }
            }
            .padding(.horizontal, Self.chartHorizontalPadding)
            .background(Color.teal.opacity(0.1))
            .cornerRadius(10)
        }
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadData()
            forexService.fetchCurrentPrice(for: pair)
        }
    }
}

// MARK: - Preview
#Preview {
    ChartView(pair: "EUR/USD")
} 