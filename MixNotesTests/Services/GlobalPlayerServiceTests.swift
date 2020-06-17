import XCTest
import Combine
@testable import MixNotes

class GlobalPlayerServiceTests: XCTestCase {
    
    var globalPlayerService: GlobalPlayerService?
    var playerService: MockPlayerService?
    
    override func setUp() {
        playerService = MockPlayerService()
        globalPlayerService = GlobalPlayerService(player: playerService!)
    }
    
    private func createMockTrack() -> Track {
        let url = URL(fileURLWithPath: "/local")
        return Track(id: "track1", title: "Track 1", version: 0, url: url)
    }
    
    private func assertIsInPlayingState() {
        XCTAssert(globalPlayerService?.state == .playing)
        XCTAssert(globalPlayerService?.isPlaying == true)
    }
    
    private func assertIsInPausedState() {
        XCTAssert(globalPlayerService?.state == .paused)
        XCTAssert(globalPlayerService?.isPlaying == false)
    }
    
    private func assertIsInErrorState() {
        XCTAssert(globalPlayerService?.state == .error)
        XCTAssert(globalPlayerService?.isPlaying == false)
    }
    
    private func assertIsSameTrack(_ track: Track) {
        XCTAssert(globalPlayerService?.currentTrack == track)
    }

    
    func testLoadAndPlay() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
    }
    
    func testLoadAndPlayInPauseState() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInPausedState()
    }
    
    func testLoadAndPlayWithSameUrl() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsInPausedState()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
    }
    
    func testLoadAndPlayErrors() {
        playerService?.isInErrorState = true
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInErrorState()
    }
    
    func testPlay() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInPausedState()
        globalPlayerService?.play()
        assertIsInPlayingState()
        
    }
    
    func testPlayErrors() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInPausedState()
        playerService?.isInErrorState = true
        globalPlayerService?.play()
        assertIsInErrorState()
    }
    
    func testPause() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
        globalPlayerService?.pause()
        assertIsInPausedState()
    }
    
    func testTogglePlayPauseFromPause() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInPausedState()
        globalPlayerService?.togglePlayPause()
        assertIsInPlayingState()
    }
    
    func testTogglePlayPauseFromPlay() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
        globalPlayerService?.togglePlayPause()
        assertIsInPausedState()
    }
}
