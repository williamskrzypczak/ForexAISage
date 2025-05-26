import SwiftUI
import Charts

// MARK: - Price Point Model
// Represents a single data point in the price chart
// Contains OHLC (Open, High, Low, Close) data and volume
struct PricePoint: Identifiable {
    let id = UUID()
    let date: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
}

// MARK: - Chart View
// Main view for displaying forex price charts with multiple chart types and timeframes
struct ChartView: View {
    // The currency pair being displayed
    let pair: String
    
    // State variables for chart configuration
    @State private var selectedTimeFrame = 0 // 0: 5M, 1: 15M, 2: 1D, 3: 1W, 4: 1M, 5: 1Y
    @State private var selectedChartType = 0
    let timeFrames = ["5M", "15M", "1D", "1W", "1M", "1Y"]
    let chartTypes = ["Line", "Candlestick", "Area"]
    
    // MARK: - Sample Data Generation
    // Generates sample price data based on selected timeframe
    // In a production app, this would be replaced with real API data
    var priceData: [PricePoint] {
        let calendar = Calendar.current
        let now = Date()
        var dateComponent: Calendar.Component
        var numberOfPoints: Int

        // Configure data points based on selected timeframe
        switch selectedTimeFrame {
        case 0: // 5M
            dateComponent = .minute
            numberOfPoints = 50 // Ensure at least 50 points
        case 1: // 15M
            dateComponent = .minute
            numberOfPoints = 50 // Ensure at least 50 points
        case 2: // 1D
            dateComponent = .hour
            numberOfPoints = 50 // Ensure at least 50 points
        case 3: // 1W
            dateComponent = .day
            numberOfPoints = 50 // Ensure at least 50 points
        case 4: // 1M
            dateComponent = .day
            numberOfPoints = 60 // Approx two months, more than 50
        case 5: // 1Y
            dateComponent = .month
            numberOfPoints = 60 // 5 years, more than 50
        default:
            dateComponent = .day
            numberOfPoints = 50
        }

        // Generate sample price data with random variations
        return (0..<numberOfPoints).map { i in
            let date = calendar.date(byAdding: dateComponent, value: -i, to: now)!
            let basePrice = 1.0875 // Base price can be dynamic in a real app
            let randomChange = Double.random(in: -0.01...0.01)
            let open = basePrice + randomChange
            let high = open + Double.random(in: 0...0.005)
            let low = open - Double.random(in: 0...0.005)
            let close = (high + low) / 2
            let volume = Double.random(in: 1000...5000)
            return PricePoint(date: date, open: open, high: high, low: low, close: close, volume: volume)
        }.reversed()
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
        VStack(spacing: 20) {
            // Chart Type Selection
            Picker("Chart Type", selection: $selectedChartType) {
                ForEach(0..<chartTypes.count, id: \.self) { index in
                    Text(chartTypes[index])
                        .font(.title3)
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Time Frame Selection
            Picker("Time Frame", selection: $selectedTimeFrame) {
                ForEach(0..<timeFrames.count, id: \.self) { index in
                    Text(timeFrames[index])
                        .font(.title3)
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            // Chart and Price Information Display
            VStack(spacing: 8) {
                // Main Chart Display
                Chart(priceData) {
                    point in
                    
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
                .frame(height: 300)
                
                // Price Information Display
                VStack(alignment: .leading, spacing: 8) {
                    Text(pair)
                        .font(.title)
                        .bold()
                    
                    // Current Price and Change
                    HStack {
                        Text("Current: 1.0875")
                            .font(.title3)
                        Spacer()
                        Text("+0.23%")
                            .font(.title3)
                            .foregroundColor(.green)
                    }
                    
                    // OHLC Information for Candlestick Chart
                    if selectedChartType == 1 {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Open: 1.0865")
                                Text("High: 1.0890")
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("Low: 1.0850")
                                Text("Close: 1.0875")
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .padding(.horizontal, Self.chartHorizontalPadding)
            .background(Color.teal.opacity(0.1))
            .cornerRadius(10)
            
            Spacer()
        }
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview
#Preview {
    ChartView(pair: "EUR/USD")
} 