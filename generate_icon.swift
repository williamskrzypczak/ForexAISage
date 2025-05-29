import SwiftUI

struct AppIcon: View {
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.teal.opacity(0.8), Color.blue.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Icon
            Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 500, height: 500)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .frame(width: 1024, height: 1024)
    }
}

// Create the icon
let icon = AppIcon()
let renderer = ImageRenderer(content: icon)
renderer.scale = 1.0

if let uiImage = renderer.uiImage {
    if let data = uiImage.pngData() {
        let url = URL(fileURLWithPath: "AppIcon.png")
        try? data.write(to: url)
        print("App icon generated successfully!")
    }
} 