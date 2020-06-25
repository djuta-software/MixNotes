import XCTest
@testable import MixNotes

class ProjectsViewModelTests: XCTestCase {

    var fileService: MockFileService?
    var noteRepository: MockNoteRepository?
    
    var projectService: ProjectService?
    var noteService: NoteService?
    var globalMessageService: GlobalMessageService?
    
    var viewModel: ProjectsViewModel?

    override func setUp() {
        fileService = MockFileService()
        noteRepository = MockNoteRepository()
        projectService = ProjectService(fileService: fileService!)
        noteService = NoteService(noteRepository: noteRepository!)
        globalMessageService = GlobalMessageService()
        viewModel = ProjectsViewModel(
            projectService: projectService!,
            noteService: noteService!,
            globalMessageService: globalMessageService!
        )
    }
    
    func testFetchProjects() {
        XCTAssert(viewModel?.currentState == .empty)
        viewModel?.fetchProjects()
        XCTAssert(viewModel?.currentState == .populated)
        for (index, project) in viewModel!.projects.enumerated() {
            let expectedTitle = "Project \(index + 1)"
            XCTAssert(project.id == expectedTitle)
            XCTAssert(project.title == expectedTitle)
        }
    }
    
    func testFetchProjectsSetsError() {
        fileService?.isInErrorState = true
        viewModel?.fetchProjects()
        XCTAssert(globalMessageService?.currentType == .error)
        XCTAssert(globalMessageService?.currentMessage == "Error fetching projects")
    }
    
    func testCreateProjectView() {
        let project = Project(id: "Project 1", title: "Project 1")
        let projectView = viewModel?.createProjectView(for: project)
        XCTAssert(type(of: projectView!) == ProjectView.self)
    }
}
