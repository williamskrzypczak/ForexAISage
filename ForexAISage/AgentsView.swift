import SwiftUI
import SafariServices

struct AgentsView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSafari = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(spacing: 10) {
                Image(systemName: "person.2.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundColor(.teal)
                    .padding()
                    .background(
                        Circle()
                            .fill(colorScheme == .dark ? Color.teal.opacity(0.2) : Color.teal.opacity(0.1))
                    )
                
                Text("Trading Agents")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.teal)
            }
            .padding(.top, 20)
            
            // Features List
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Market Analysis", description: "Get real-time market insights and trend analysis")
                FeatureRow(icon: "lightbulb.fill", title: "Trading Ideas", description: "Receive personalized trading suggestions based on market conditions")
                FeatureRow(icon: "text.bubble.fill", title: "Expert Guidance", description: "Ask questions and get detailed explanations from our AI")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Launch Button
            Button(action: {
                showingSafari = true
            }) {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Launch Trading Agents")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.teal, .blue]), startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(15)
                .shadow(color: .teal.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(colorScheme == .dark ? Color.black : Color.white)
        .sheet(isPresented: $showingSafari) {
            AgentsTabView()
        }
    }
}

struct AgentsTabView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Tab Bar with improved visibility
                HStack(spacing: 0) {
                    TabButton(
                        title: "Market Analysis",
                        icon: "chart.line.uptrend.xyaxis",
                        isSelected: selectedTab == 0
                    ) {
                        withAnimation {
                            selectedTab = 0
                        }
                    }
                    
                    TabButton(
                        title: "Trading Strategy",
                        icon: "list.bullet.clipboard",
                        isSelected: selectedTab == 1
                    ) {
                        withAnimation {
                            selectedTab = 1
                        }
                    }
                }
                .background(Color(UIColor.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3)),
                    alignment: .bottom
                )
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    SafariView(url: URL(string: "https://udify.app/chatbot/7Ycv9Vj2MOA9LPrr")!)
                        .tag(0)
                        .edgesIgnoringSafeArea(.all)
                    
                    SafariView(url: URL(string: "https://udify.app/chatbot/rSwemwAbIFVVeQTG")!)
                        .tag(1)
                        .edgesIgnoringSafeArea(.all)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.all)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.subheadline)
            }
            .foregroundColor(isSelected ? .teal : .gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                VStack {
                    Spacer()
                    if isSelected {
                        Rectangle()
                            .fill(Color.teal)
                            .frame(height: 3)
                    }
                }
            )
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.teal)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(colorScheme == .dark ? .gray.opacity(0.8) : .gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        )
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = false
        
        let safariVC = SFSafariViewController(url: url, configuration: config)
        safariVC.preferredControlTintColor = .systemTeal
        
        // Set the background color to match the app's theme
        if let window = UIApplication.shared.windows.first {
            window.backgroundColor = UIColor.systemBackground
        }
        
        // Configure the appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}

#Preview {
    AgentsView()
        .preferredColorScheme(.dark)
} 