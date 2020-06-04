import Foundation

class ProjectsViewModel: ObservableObject {
    
    let projectService: ProjectServiceProtocol
    let noteService: NoteServiceProtocol
    let globalMessageService: GlobalMessageServiceProtocol
    
    @Published var projects: [Project] = []
    
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
            projects = try projectService.getProjects()
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
