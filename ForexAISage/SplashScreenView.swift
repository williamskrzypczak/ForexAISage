import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack {
                VStack(spacing: 20) {
                    // Company Logo
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.teal)
                        .background(
                            Circle()
                                .fill(colorScheme == .dark ? Color.teal.opacity(0.2) : Color.teal.opacity(0.1))
                        )
                        .frame(width: 160, height: 160)
                    
                    // Main App Name
                    Text("ForexAISage")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.teal)
                    
                    // Company Name
                    Text("by Waverider Trading Technologies")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .blue.opacity(0.8) : .blue)
                    
                    // Tagline
                    Text("AI-Powered Forex Trading")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
                }
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .dark ? Color.black : Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .preferredColorScheme(.dark)
} 