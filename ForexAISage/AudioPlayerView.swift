import SwiftUI
import AVKit

class AudioPlayerManager: ObservableObject {
    private var player: AVPlayer?
    @Published var isPlaying = false
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
    @Published var playbackRate: Float = 1.0
    @Published var autoPlayNext: Bool {
        didSet {
            UserDefaults.standard.set(autoPlayNext, forKey: "autoPlayNext")
        }
    }
    private var timeObserver: Any?
    private var playerItemObserver: NSKeyValueObservation?
    
    let availableRates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
    
    init() {
        self.autoPlayNext = UserDefaults.standard.bool(forKey: "autoPlayNext")
    }
    
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
        
        // Observe when playback ends
        playerItemObserver = playerItem.observe(\.status) { [weak self] item, _ in
            if item.status == .failed {
                print("Playback failed")
            }
        }
        
        // Add notification observer for playback end
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    @objc private func playerDidFinishPlaying() {
        if autoPlayNext {
            // Notify the view to play the next episode
            NotificationCenter.default.post(name: .playNextEpisode, object: nil)
        }
    }
    
    func play() {
        player?.play()
        player?.rate = playbackRate
        isPlaying = true
    }
    
    func pause() {
        player?.pause()
        isPlaying = false
    }
    
    func seek(to time: Double) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 600))
    }
    
    func setPlaybackRate(_ rate: Float) {
        playbackRate = rate
        if isPlaying {
            player?.rate = rate
        }
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
        playerItemObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
}

// Notification name for playing next episode
extension Notification.Name {
    static let playNextEpisode = Notification.Name("playNextEpisode")
}

struct AudioPlayerView: View {
    let episode: PodcastEpisode
    let isAutoPlayingNext: Bool
    @StateObject private var playerManager = AudioPlayerManager()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    
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
            
            // Auto-play Toggle
            Toggle(isOn: $playerManager.autoPlayNext) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.teal)
                    Text("Auto-play Next Episode")
                        .foregroundColor(.primary)
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .teal))
            .padding(.horizontal)
            
            // Playback Speed Controls
            HStack(spacing: 12) {
                ForEach(playerManager.availableRates, id: \.self) { rate in
                    Button(action: {
                        playerManager.setPlaybackRate(rate)
                    }) {
                        Text(String(format: "%.2fx", rate))
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                playerManager.playbackRate == rate ?
                                Color.teal :
                                (colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(
                                playerManager.playbackRate == rate ?
                                .white :
                                .teal
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
            
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
            if isAutoPlayingNext {
                // Small delay to ensure audio is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playerManager.play()
                }
            }
        }
    }
} 