import Foundation

class ProjectViewModel: ObservableObject {
    
    enum State {
        case empty, populated, loading
    }
    
    let project: Project
    let projectService: ProjectServiceProtocol
    let noteService: NoteServiceProtocol
    let globalMessageService: GlobalMessageServiceProtocol
    
    @Published var tracks: [Track] = []
    @Published var currentState = State.empty
    
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
            currentState = .loading
            tracks = try projectService.getTracks(for: project)
            currentState = tracks.isEmpty ? .empty : .populated
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
