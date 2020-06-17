import XCTest
@testable import MixNotes

class TrackViewModelTests: XCTestCase {

    var fileService: MockFileService?
    var noteRepository: MockNoteRepository?
    
    var projectService: ProjectService?
    var noteService: NoteService?
    var globalMessageService: GlobalMessageService?
    
    var viewModel: TrackViewModel?

    let testTrack = Track(
        id: "Project 1-Track 1",
        title: "Track 1",
        version: 0,
        url: URL(fileURLWithPath: "/remote/Project 1/Track 1")
    )

    let testLocalTrack = Track(
        id: "Project 1-Track 1",
        title: "Track 1",
        version: 0,
        url: URL(fileURLWithPath: "/local/Project 1/Track 1")
    )
    
    func createViewModel(track: Track) -> TrackViewModel {
        fileService = MockFileService()
        noteRepository = MockNoteRepository()
        projectService = ProjectService(fileService: fileService!)
        noteService = NoteService(noteRepository: noteRepository!)
        globalMessageService = GlobalMessageService()
        for n in 1...3 {
            let timestamp = n * 10
            _ = noteRepository?.addNote(for: testTrack, at: timestamp, text: "This is note \(n)")
        }
        return TrackViewModel(
            track: track,
            projectService: projectService!,
            noteService: noteService!,
            globalMessageService: globalMessageService!
        )
    }
    
    override func setUp() {
        viewModel = createViewModel(track: testTrack)
    }
    
    func testFetchNotes() {
        let expectation = XCTestExpectation(description: "Get notes should succeed")
        viewModel?.fetchNotes()
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            let notes = self.viewModel!.notes
            XCTAssert(notes.count == 3)
            for (index, note) in notes.enumerated() {
                let n = index + 1
                XCTAssert(note.text == "This is note \(n)")
                XCTAssert(note.timestamp == n * 10)
            }
        }
    }
    
    func testFetchNotesErrors() {
        let expectation = XCTestExpectation(description: "Get notes should error")
        noteRepository?.isInErrorState = true
        viewModel?.fetchNotes()
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel!.notes.isEmpty)
            XCTAssert(self.globalMessageService?.currentType == .error)
            XCTAssert(self.globalMessageService?.currentMessage == "Error fetching notes")
        }
    }
    
    func testCheckIfTrackIsDownloadedCurrent() {
        fileService?.downloadStatus = .current
        viewModel?.checkIfTrackIsDownloaded()
        XCTAssert(viewModel?.downloadStatus == .current)
    }
    
    func testCheckIfTrackIsDownloadedStale() {
        fileService?.downloadStatus = .downloaded
        viewModel?.checkIfTrackIsDownloaded()
        XCTAssert(viewModel?.downloadStatus == .stale)
    }
    
    func testCheckIfTrackDownloadedRemote() {
        fileService?.downloadStatus = .notDownloaded
        viewModel?.checkIfTrackIsDownloaded()
        XCTAssert(viewModel?.downloadStatus == .remote)
    }
    
    func testDownloadTrack() {
        let expectation = XCTestExpectation(description: "Download track should succeed")
        viewModel?.downloadTrack()
        XCTAssert(viewModel?.downloadStatus == .downloading)
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel?.track.url.path == "/local/Project 1/Track 1")
        }
    }
    
    func testDownloadTrackErrors() {
        let expectation = XCTestExpectation(description: "Download track should error")
        fileService?.isInErrorState = true
        viewModel?.downloadTrack()
        XCTAssert(viewModel?.downloadStatus == .downloading)
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel?.track.url.path == "/remote/Project 1/Track 1")
            XCTAssert(self.globalMessageService?.currentMessage == "Download Failed")
            XCTAssert(self.globalMessageService?.currentType == .error)
        }
    }
    
    func testEvictTrack() {
        let expectation = XCTestExpectation(description: "Evict track should succeed")
        viewModel = createViewModel(track: testLocalTrack)
        viewModel?.evictTrack()
        XCTAssert(viewModel?.downloadStatus == .evicting)
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel?.track.url.path == "/remote/Project 1/Track 1")
            XCTAssert(self.globalMessageService?.currentMessage == "Track Removed")
            XCTAssert(self.globalMessageService?.currentType == .info)
        }
    }
    
    func testEvictTrackErrors() {
        let expectation = XCTestExpectation(description: "Evict track should fail")
        viewModel = createViewModel(track: testLocalTrack)
        fileService?.isInErrorState = true
        viewModel?.evictTrack()
        XCTAssert(viewModel?.downloadStatus == .evicting)
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel?.track.url.path == "/local/Project 1/Track 1")
            XCTAssert(self.globalMessageService?.currentMessage == "Eviction Failed")
            XCTAssert(self.globalMessageService?.currentType == .error)
        }
        
    }
    
    func testAddNote() {
        let expectation = XCTestExpectation(description: "Add note should succeed")
        viewModel?.addNote(at: 10, text: "This is a new note!")
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            let note = self.viewModel?.notes.first
            XCTAssert(self.viewModel?.notes.count == 1)
            XCTAssert(note?.text == "This is a new note!")
            XCTAssert(note?.timestamp == 10)
            XCTAssert(self.globalMessageService?.currentMessage == "Note Saved!")
            XCTAssert(self.globalMessageService?.currentType == .success)
        }
    }
    
    func testAddNoteErrors() {
        let expectation = XCTestExpectation(description: "Add note should error")
        noteRepository?.isInErrorState = true
        viewModel?.addNote(at: 10, text: "This is a new note!")
        MixNotes_XCTAssertWithDelay(expectation: expectation) {
            XCTAssert(self.viewModel?.notes.count == 0)
            XCTAssert(self.globalMessageService?.currentMessage == "Note insert failed")
            XCTAssert(self.globalMessageService?.currentType == .error)
        }
    }
    
    func testDeleteNote() {
        let expectation = XCTestExpectation(description: "Add note should error")
        viewModel?.addNote(at: 10, text: "This is a new note!")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            let note = self.viewModel?.notes.first
            self.viewModel?.deleteNote(note!)
        }
        MixNotes_XCTAssertWithDelay(expectation: expectation, delay: 2) {
            XCTAssert(self.viewModel?.notes.count == 0)
            XCTAssert(self.globalMessageService?.currentMessage == "Note deleted!")
            XCTAssert(self.globalMessageService?.currentType == .info)
        }
    }
    
    func testDeleteNoteErrors() {
        let expectation = XCTestExpectation(description: "Add note should error")
        viewModel?.addNote(at: 10, text: "This is a new note!")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.noteRepository?.isInErrorState = true
            let note = self.viewModel?.notes.first
            self.viewModel?.deleteNote(note!)
        }
        MixNotes_XCTAssertWithDelay(expectation: expectation, delay: 2) {
            XCTAssert(self.viewModel?.notes.count == 1)
            XCTAssert(self.globalMessageService?.currentMessage == "Note deletion failed")
            XCTAssert(self.globalMessageService?.currentType == .error)
        }
    }
}
