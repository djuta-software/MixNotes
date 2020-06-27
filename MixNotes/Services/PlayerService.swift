import Foundation
import AVFoundation

protocol PlayerServiceProtocol {
    var delegate: PlayerServiceDelegate? { get set }
    var url: URL? { get }
    var isPlaying: Bool { get }
    var duration: Double { get }
    func load(url: URL, shouldPlay: Bool) throws
    func play() throws
    func pause()
    func skipBackward(numberOfSeconds: Double)
    func skipForward(numberOfSeconds: Double)
    func setTime(_ time: Double)
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
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch {
            print(error)
        }

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
        guard let currentTime = self.player?.currentTime else { return }
        let targetTime = currentTime - numberOfSeconds
        setTime(targetTime)
    }
    
    func skipForward(numberOfSeconds: Double) {
        guard let currentTime = self.player?.currentTime else { return }
        let targetTime = currentTime + numberOfSeconds
        setTime(targetTime)
    }
    
    func setTime(_ time: Double) {
        guard let player = self.player else {
            return
        }
        var targetTime = time
        if(targetTime < 0) {
            targetTime = 0
        }
        if(targetTime > player.duration) {
            targetTime = player.duration
        }
        player.currentTime = targetTime
        self.delegate?.onCurrentTimeUpdate(currentTime: player.currentTime)
    }
    
    var url: URL?  {
        return player?.url
    }
    
    var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    var duration: Double {
        return player?.duration ?? 0
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
