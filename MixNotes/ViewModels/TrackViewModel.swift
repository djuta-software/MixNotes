import Foundation

class TrackViewModel: ObservableObject {

    enum DownloadStatus: String {
        case current = "Downloaded"
        case stale = "Out of Date"
        case remote = "Not Downloaded"
        case downloading = "Downloading..."
        case error = "Error"
        case evicting = "Evicting..."
    }
    
    let projectService: ProjectServiceProtocol
    let noteService: NoteServiceProtocol
    let globalMessageService: GlobalMessageServiceProtocol

    @Published var track: Track
    @Published var notes: [Note] = []
    @Published var downloadStatus: DownloadStatus = .remote
    
    init(
        track: Track,
        projectService: ProjectServiceProtocol,
        noteService: NoteServiceProtocol,
        globalMessageService: GlobalMessageServiceProtocol
    ) {
        self.track = track
        self.projectService = projectService
        self.noteService = noteService
        self.globalMessageService = globalMessageService
    }
    
    func fetchNotes() {
        _ = noteService.getNotes(for: track)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.globalMessageService.setErrorMessage("Error fetching notes")
                case .finished:
                    self.globalMessageService.setSuccessMessage("Notes fetched")
                }
            }, receiveValue: {
                self.notes = $0
            })
    }
    
    func checkIfTrackIsDownloaded() {
        let status = projectService.getTrackDownloadStatus(track)
        switch status {
        case .downloaded:
            downloadStatus = .current   
        case .stale:
            downloadStatus = .stale
        case .error:
            downloadStatus = .error
        case .notDownloaded:
            downloadStatus = .remote
        }
    }
    
    func downloadTrack() {
        downloadStatus = .downloading
        _ = projectService.downloadTrack(track)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.globalMessageService.setErrorMessage("Download Failed")
                case .finished:
                    self.globalMessageService.setSuccessMessage("Download Successful!")
                }
                self.checkIfTrackIsDownloaded()
            }, receiveValue: { self.track.url = $0 })
    }
    
    func evictTrack() {
        downloadStatus = .evicting
        _ = projectService.evictTrack(track)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.globalMessageService.setErrorMessage("Eviction Failed")
                case .finished:
                    self.globalMessageService.setSuccessMessage("Eviction Successful!")
                    self.downloadStatus = .remote
                }
            }, receiveValue: { self.track.url = $0 })
    }
    
    func addNote(at timestamp: Int, text: String) {
        _ = noteService.addNote(for: track, at: timestamp, text: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.globalMessageService.setErrorMessage("Note insert failed")
                case .finished:
                    self.globalMessageService.setSuccessMessage("Note Saved!")
                }
            }, receiveValue: { self.insertNewNote($0) })
    }
    
    func deleteNote(_ note: Note) {
        _ = noteService.deleteNote(note)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.globalMessageService.setErrorMessage("Note deletion failed")
                case .finished:
                    self.globalMessageService.setSuccessMessage("Note deleted!")
                    self.notes.removeAll { $0.id == note.id }
                }         
            }, receiveValue: { _ in })
    }
    
    private func insertNewNote(_ note: Note) {
        guard let index = notes.firstIndex(where: { $0.timestamp > note.timestamp }) else {
            notes.append(note)
            return
        }
        self.notes.insert(note, at: index)
    }
}
