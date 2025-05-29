import SwiftUI

struct PodcastEpisode: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let date: Date
    let duration: String
    let audioURL: URL
}

struct PodcastEpisodesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var episodes: [PodcastEpisode] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedEpisode: PodcastEpisode?
    @State private var refreshTimer: Timer?
    @State private var currentEpisodeIndex: Int?
    @State private var isAutoPlayingNext = false
    
    // Refresh interval in seconds (5 minutes)
    private let refreshInterval: TimeInterval = 300
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading episodes...")
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                        Button("Retry") {
                            loadEpisodes()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    ZStack {
                        List {
                            Section {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 8) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.teal)
                                        Text("Pull Down To Refresh")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                                .listRowBackground(Color.clear)
                                .padding(.vertical, 8)
                            }
                            
                            ForEach(Array(episodes.enumerated()), id: \.element.id) { index, episode in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(episode.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(episode.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(3)
                                    
                                    HStack {
                                        Label(episode.date.formatted(date: .abbreviated, time: .omitted),
                                              systemImage: "calendar")
                                        Spacer()
                                        Label(episode.duration,
                                              systemImage: "clock")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.teal)
                                    
                                    Button(action: {
                                        currentEpisodeIndex = index
                                        isAutoPlayingNext = false
                                        selectedEpisode = episode
                                    }) {
                                        HStack {
                                            Image(systemName: "play.circle.fill")
                                            Text("Play Episode")
                                        }
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                         startPoint: .leading,
                                                         endPoint: .trailing)
                                        )
                                        .cornerRadius(10)
                                        .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .refreshable {
                            await loadEpisodesAsync()
                        }
                    }
                }
            }
            .navigationTitle("FX Morning Mayhem")
            .background(colorScheme == .dark ? Color.black : Color.white)
            .sheet(item: $selectedEpisode) { episode in
                AudioPlayerView(episode: episode, isAutoPlayingNext: isAutoPlayingNext)
            }
        }
        .onAppear {
            loadEpisodes()
            startRefreshTimer()
            setupNotificationObserver()
        }
        .onDisappear {
            stopRefreshTimer()
            removeNotificationObserver()
        }
    }
    
    private func loadEpisodes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await loadEpisodesAsync()
        }
    }
    
    private func loadEpisodesAsync() async {
        do {
            episodes = try await PodcastService.shared.fetchEpisodes()
            isLoading = false
        } catch {
            errorMessage = "Failed to load episodes: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    private func startRefreshTimer() {
        // Stop any existing timer
        stopRefreshTimer()
        
        // Create a new timer that fires every refreshInterval seconds
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { _ in
            loadEpisodes()
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .playNextEpisode,
            object: nil,
            queue: .main
        ) { _ in
            self.playNextEpisode()
        }
    }
    
    private func removeNotificationObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func playNextEpisode() {
        guard let currentIndex = currentEpisodeIndex,
              currentIndex + 1 < episodes.count else {
            return
        }
        
        let nextEpisode = episodes[currentIndex + 1]
        currentEpisodeIndex = currentIndex + 1
        isAutoPlayingNext = true
        
        // Dismiss current player and show next episode
        selectedEpisode = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            selectedEpisode = nextEpisode
        }
    }
}

#Preview {
    PodcastEpisodesView()
        .preferredColorScheme(.dark)
} 