import Foundation

enum MockPlayerServiceError: Error {
    case loadFailure, playFailure
}

class MockPlayerService: PlayerServiceProtocol {
    var delegate: PlayerServiceDelegate?
    
    var url: URL?
    var isInErrorState = false
    var isPlaying  = false

    func load(url: URL, shouldPlay: Bool) throws {
        isPlaying = false
        self.url = url
        if isInErrorState {
            throw MockPlayerServiceError.loadFailure
        }
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
}
