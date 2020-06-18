import Foundation
import AVFoundation

protocol PlayerServiceProtocol {
    var delegate: PlayerServiceDelegate? { get set }
    var url: URL? { get }
    var isPlaying: Bool { get }
    func load(url: URL, shouldPlay: Bool) throws
    func play() throws
    func pause()
    func skipBackward(numberOfSeconds: Double)
    func skipForward(numberOfSeconds: Double)
}

enum PlayerServiceError: Error {
    case loadFailure
    case playFailure
}

protocol PlayerServiceDelegate {
    func onTrackEnd()
    func onCurrentTimeUpdate(currentTime: Double)
}


// TODO: Replace implementation with AVPlayer
class PlayerService: NSObject, PlayerServiceProtocol {
    
    var player: AVAudioPlayer?
    var delegate: PlayerServiceDelegate?
    weak var timer: Timer?
    
    override init() {
        super.init()
    }
    
    func load(url: URL, shouldPlay: Bool = true) throws {
        do {
            delegate?.onCurrentTimeUpdate(currentTime: 0)
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
        } catch {
            throw PlayerServiceError.loadFailure
        }
        if shouldPlay {
            try play()
        }
    }
    
    func play() throws {
        let isSuccessful = player?.play() ?? false
        if(!isSuccessful) {
            throw PlayerServiceError.playFailure
        }
        setTimer()
    }
    
    func pause() {
        player?.pause()
        invalidateTimer()
    }
    
    func skipBackward(numberOfSeconds: Double) {
        guard let player = self.player else {
            return
        }
        let targetTime = player.currentTime - numberOfSeconds
        let newTime = targetTime > 0 ? targetTime : 0
        player.currentTime = newTime
    }
    
    func skipForward(numberOfSeconds: Double) {
        guard let player = self.player else {
            return
        }
        let targetTime = player.currentTime + numberOfSeconds
        let newTime = targetTime < player.duration ? targetTime : player.duration
        player.currentTime = newTime
    }
    
    var url: URL?  {
        return player?.url
    }
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    private func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.delegate?.onCurrentTimeUpdate(currentTime: self?.player?.currentTime ?? 0)
        }
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension PlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.onTrackEnd()
    }
}
