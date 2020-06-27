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
        return Track(id: "track1", title: "Track 1", lastModified: Date(), url: url)
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
    
    private func assertDurationIsSet() {
        XCTAssert(globalPlayerService?.duration == playerService?.duration)
    }

    
    func testLoadAndPlay() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
        assertDurationIsSet()
        
    }
    
    func testLoadAndPlayInPauseState() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInPausedState()
        assertDurationIsSet()
    }
    
    func testLoadAndPlayWithSameUrl() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsInPausedState()
        globalPlayerService?.loadAndPlay(track)
        assertIsSameTrack(track)
        assertIsInPlayingState()
        assertDurationIsSet()
    }
    
    func testLoadAndPlayErrors() {
        playerService?.isInErrorState = true
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track, shouldPlay: false)
        assertIsSameTrack(track)
        assertIsInErrorState()
        XCTAssert(globalPlayerService?.duration == 0)
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
    
    func testSkipBackward() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        playerService?.currentTime = 27
        globalPlayerService?.skipBackward(numberOfSeconds: 10)
        XCTAssert(playerService?.currentTime == 17)
    }
    
    func testSkipForward() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        playerService?.currentTime = 27
        globalPlayerService?.skipForward(numberOfSeconds: 10)
        XCTAssert(playerService?.currentTime == 37)
    }
    
    func testOnTrackEnd() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        assertIsInPlayingState()
        globalPlayerService?.onTrackEnd()
        assertIsInPausedState()
        XCTAssert(globalPlayerService?.currentTime == 0)
    }
    
    func testOnCurrentTimeUpdate() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        XCTAssert(globalPlayerService?.currentTime == 0)
        globalPlayerService?.onCurrentTimeUpdate(currentTime: 27)
        XCTAssert(globalPlayerService?.currentTime == 27)
    }
    
    func testCurrentTimeDoesntUpdateWhenScrubbing() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        XCTAssert(globalPlayerService?.currentTime == 0)
        globalPlayerService?.isScrubbing = true
        globalPlayerService?.onCurrentTimeUpdate(currentTime: 27)
        XCTAssert(globalPlayerService?.currentTime == 0)
    }
    
    func testSettingIsScrubbingFalseUpdatesPlayerCurrentTime() {
        let track = createMockTrack()
        globalPlayerService?.loadAndPlay(track)
        globalPlayerService?.currentTime = 27
        globalPlayerService?.isScrubbing = true
        globalPlayerService?.isScrubbing = false
        XCTAssert(playerService?.currentTime == 27)   
    }
}
