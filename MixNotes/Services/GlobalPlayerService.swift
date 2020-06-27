import Foundation
import AVFoundation

enum GlobalPlayerServiceState: String {
    case playing = "Pause"
    case paused = "Play"
    case loading = "Loading"
    case error = "Error"
    case stopped = "Stopped"
}

class GlobalPlayerService: ObservableObject {
    
    @Published private(set) var state: GlobalPlayerServiceState = .stopped
    @Published private(set) var currentTrack: Track?
    @Published var currentTime: Double = 0
    @Published private(set) var duration: Double = 0
    @Published var isScrubbing = false {
        didSet {
            if !isScrubbing {
                player.setTime(currentTime)
            }
        }
    }

    var player: PlayerServiceProtocol

    init(player: PlayerServiceProtocol) {
        self.player = player
        self.player.delegate = self
    }
    
    func loadAndPlay(_ track: Track, shouldPlay: Bool = true) {
        if player.url == track.url && shouldPlay {
            play()
            return
        }
        do {
            currentTrack = track
            try player.load(url: track.url, shouldPlay: shouldPlay)
            state = shouldPlay ? .playing : .paused
            duration = player.duration
        } catch {
            state = .error
        }
    }
    
    func play() {
        do {
            try player.play()
            state = .playing
        } catch {
            state = .error
        }
    }
    
    func pause() {
        player.pause()
        state = .paused
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    func skipBackward(numberOfSeconds: Double) {
        player.skipBackward(numberOfSeconds: numberOfSeconds)
    }
    
    func skipForward(numberOfSeconds: Double) {
        player.skipForward(numberOfSeconds: numberOfSeconds)
    }
    
    var isPlaying: Bool {
        return player.isPlaying
    }


}

extension GlobalPlayerService: PlayerServiceDelegate {    
    func onTrackEnd() {
        guard let track = currentTrack else { return }
        loadAndPlay(track, shouldPlay: false)
    }
    
    func onCurrentTimeUpdate(currentTime: Double) {
        if !isScrubbing {
            self.currentTime = currentTime
        }
    }
}
