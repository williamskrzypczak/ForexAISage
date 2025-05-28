import SwiftUI
import AVKit

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    private var timeObserver: Any?
    
    func loadAudio(from url: URL) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observe duration
        playerItem.asset.loadValuesAsynchronously(forKeys: ["duration"]) { [weak self] in
            DispatchQueue.main.async {
                self?.duration = playerItem.asset.duration.seconds
            }
        }
        
        // Observe current time
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
        }
    }
    
    func play() {
        player?.play()
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    deinit {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
        }
    }
}

struct AudioPlayerView: View {
    let episode: PodcastEpisode
    @StateObject private var playerManager = AudioPlayerManager()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Episode Info
            VStack(spacing: 12) {
                Text(episode.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Text(episode.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                Slider(value: Binding(
                    get: { playerManager.currentTime },
                    set: { playerManager.seek(to: $0) }
                ), in: 0...max(playerManager.duration, 1))
                .accentColor(.teal)
                
                HStack {
                    Text(playerManager.formatTime(playerManager.currentTime))
                    Spacer()
                    Text(playerManager.formatTime(playerManager.duration))
                }
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            // Playback Controls
            HStack(spacing: 40) {
                Button(action: {
                    playerManager.seek(to: max(0, playerManager.currentTime - 15))
                }) {
                    Image(systemName: "gobackward.15")
                        .font(.title)
                        .foregroundColor(.teal)
                }
                
                Button(action: {
                    if playerManager.isPlaying {
                        playerManager.pause()
                    } else {
                        playerManager.play()
                    }
                }) {
                    Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.teal)
                }
                
                Button(action: {
                    playerManager.seek(to: min(playerManager.duration, playerManager.currentTime + 15))
                }) {
                    Image(systemName: "goforward.15")
                        .font(.title)
                        .foregroundColor(.teal)
                }
            }
            .padding()
            
            // Close Button
            Button("Close") {
                dismiss()
            }
            .foregroundColor(.teal)
            .padding()
        }
        .padding()
        .onAppear {
            playerManager.loadAudio(from: episode.audioURL)
        }
    }
} 