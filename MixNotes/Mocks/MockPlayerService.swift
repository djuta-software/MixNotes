import Foundation

enum MockPlayerServiceError: Error {
    case loadFailure, playFailure
}

class MockPlayerService: PlayerServiceProtocol {
    var delegate: PlayerServiceDelegate?
    
    var url: URL?
    var isInErrorState = false
    var isPlaying = false
    var currentTime = 0.0
    var duration = 0.0

    func load(url: URL, shouldPlay: Bool) throws {
        isPlaying = false
        self.url = url
        if isInErrorState {
            throw MockPlayerServiceError.loadFailure
        }
        duration = 10
        if shouldPlay {
            try play()
        }
    }
    
    func play() throws {
        if isInErrorState {
            throw MockPlayerServiceError.playFailure
        }
        isPlaying = true
    }
    
    func pause() {
        isPlaying = false
    }
    
    func skipBackward(numberOfSeconds: Double) {
        currentTime = currentTime - numberOfSeconds
    }
    
    func skipForward(numberOfSeconds: Double) {
        currentTime = currentTime + numberOfSeconds
    }
    
    func setTime(_ time: Double) {
        currentTime = time
    }
}
