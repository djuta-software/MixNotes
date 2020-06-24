import Foundation

class ProjectsViewModel: ObservableObject {
    
    enum State {
        case empty, populated, loading
    }
    
    let projectService: ProjectServiceProtocol
    let noteService: NoteServiceProtocol
    let globalMessageService: GlobalMessageServiceProtocol
    
    @Published var projects: [Project] = []
    @Published var currentState = State.empty
    
    init(
        projectService: ProjectServiceProtocol,
        noteService: NoteServiceProtocol,
        globalMessageService: GlobalMessageServiceProtocol
    ) {
        self.projectService = projectService
        self.noteService = noteService
        self.globalMessageService = globalMessageService
    }
    
    func fetchProjects() {
        do {
            currentState = .loading
            projects = try projectService.getProjects()
            currentState = projects.isEmpty ? .empty : .populated
        } catch {
            globalMessageService.setErrorMessage("Error fetching projects")
        }  
    }
    
    func createProjectView(for project: Project) -> ProjectView {
        let viewModel = ProjectViewModel(
            project: project,
            projectService: projectService,
            noteService: noteService,
            globalMessageService: globalMessageService
        )
        return ProjectView(viewModel: viewModel)
    }
}
