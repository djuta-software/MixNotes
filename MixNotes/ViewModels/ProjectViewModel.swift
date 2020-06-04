import Foundation

class ProjectViewModel: ObservableObject {
    
    let project: Project
    let projectService: ProjectServiceProtocol
    let noteService: NoteServiceProtocol
    let globalMessageService: GlobalMessageServiceProtocol
    
    @Published var tracks: [Track] = []
    
    init(
        project: Project,
        projectService: ProjectServiceProtocol,
        noteService: NoteServiceProtocol,
        globalMessageService: GlobalMessageServiceProtocol
    ) {
        self.project = project
        self.projectService = projectService
        self.noteService = noteService
        self.globalMessageService = globalMessageService
    }
    
    func fetchTracks() {
        do {
            tracks = try projectService.getTracks(for: project)
        } catch {
            globalMessageService.setErrorMessage("Error fetching tracks")
        }
    }
    
    func createTrackView(for track: Track) -> TrackView {
        let viewModel = TrackViewModel(
            track: track,
            projectService: projectService,
            noteService: noteService,
            globalMessageService: globalMessageService
        )
        return TrackView(viewModel: viewModel)
    }
}
