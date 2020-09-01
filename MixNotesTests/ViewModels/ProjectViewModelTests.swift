import XCTest
@testable import MixNotes

class ProjectViewModelTests: XCTestCase {

    var fileService: MockFileService?
    var noteRepository: MockNoteRepository?
    
    var projectService: ProjectService?
    var noteService: NoteService?
    var globalMessageService: GlobalMessageService?
    
    var viewModel: ProjectViewModel?

    override func setUp() {
        let project = Project(id: "project1", title: "Project 1")
        fileService = MockFileService()
        noteRepository = MockNoteRepository()
        projectService = ProjectService(fileService: fileService!)
        noteService = NoteService(noteRepository: noteRepository!)
        globalMessageService = GlobalMessageService()
        viewModel = ProjectViewModel(
            project: project,
            projectService: projectService!,
            noteService: noteService!,
            globalMessageService: globalMessageService!
        )
    }
    
    func testFetchTracks() {
        XCTAssert(viewModel?.currentState == .empty)
        viewModel?.fetchTracks()
        XCTAssert(viewModel?.currentState == .populated)
        for (index, track) in viewModel!.tracks.enumerated() {
            let expectedTitle = "Track \(index + 1)"
            XCTAssert(track.id == "Project 1-\(expectedTitle)")
            XCTAssert(track.title == expectedTitle)
            XCTAssert(track.url == URL(fileURLWithPath: "/remote/Project 1/\(expectedTitle)"))
        }
    }
    
    func testFetchTracksSetsError() {
        fileService?.isInErrorState = true
        viewModel?.fetchTracks()
        XCTAssert(globalMessageService?.currentType == .error)
        XCTAssert(globalMessageService?.currentMessage == "Error fetching tracks")
    }
    
    func testCreateTrackView() {
        let url = URL(fileURLWithPath: "/local/Project 1/Track 1.wav")
        let track = Track(id: "Track 1", title: "Track 1", lastModified: Date(), url: url)
        let trackView = viewModel?.createTrackView(for: track)
        XCTAssert(type(of: trackView!) == TrackView.self)
    }
}
