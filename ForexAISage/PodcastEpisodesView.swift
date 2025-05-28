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
                    List(episodes) { episode in
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
            }
            .navigationTitle("FX Morning Mayhem")
            .background(colorScheme == .dark ? Color.black : Color.white)
            .sheet(item: $selectedEpisode) { episode in
                AudioPlayerView(episode: episode)
            }
        }
        .onAppear {
            loadEpisodes()
        }
    }
    
    private func loadEpisodes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                episodes = try await PodcastService.shared.fetchEpisodes()
                isLoading = false
            } catch {
                errorMessage = "Failed to load episodes: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
}

#Preview {
    PodcastEpisodesView()
        .preferredColorScheme(.dark)
} 