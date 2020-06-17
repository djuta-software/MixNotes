import Foundation
import Combine
import SwiftUI

struct PreviewUtils {
    static func createPreviewTrackView() -> some View {
        let track = Track(
            id: "testtrack",
            title: "Test Track",
            version: 2,
            url: URL(fileURLWithPath: "/filesystem/track.wav")
        )
        let viewModel = TrackViewModel(
            track: track,
            projectService: PreviewProjectService(),
            noteService: PreviewNoteService(),
            globalMessageService: GlobalMessageService()
        )
        let globalPlayerService = GlobalPlayerService(player: MockPlayerService())
        globalPlayerService.loadAndPlay(track, shouldPlay: false)
        viewModel.notes.append(
            Note(id: "123", timestamp: 0, text: "This is a really good note")
        )
        return NavigationView {
            TrackView(viewModel: viewModel)
                .environmentObject(globalPlayerService)
        }

    }
    
    static func createPreviewProjectView(numberOfItems: Int = 3) -> some View {
        let project = Project(id: "Test Project", title: "Test Project")
        let viewModel = ProjectViewModel(
            project: project,
            projectService: PreviewProjectService(),
            noteService: PreviewNoteService(),
            globalMessageService: GlobalMessageService()
        )
        for index in 1...numberOfItems {
            let track = Track(
                id: "track\(index)",
                title: "Track \(index)",
                version: 1,
                url: URL(fileURLWithPath: "/filesystem/file\(index).wav")
            )
            viewModel.tracks.append(track)
        }
        return NavigationView {
            ProjectView(viewModel: viewModel)
        }
    }
    
    static func createPreviewProjectsView(numberOfItems: Int = 3) -> some View {
        let viewModel = ProjectsViewModel(
            projectService: PreviewProjectService(),
            noteService: PreviewNoteService(),
            globalMessageService: GlobalMessageService()
        )
        for index in 1...numberOfItems {
            let project = Project(id: "project\(index)", title: "Project \(index)")
            viewModel.projects.append(project)
        }
        return NavigationView {
            ProjectsView(viewModel: viewModel)
        }
    }
    
    static func createPreviewGlobalMessageView() -> some View {
        let globalMessageService = GlobalMessageService()
        globalMessageService.setInfoMessage("This is a message")
        return GlobalMessageView(globalMessageService: globalMessageService)
    }
}

fileprivate struct PreviewProjectService: ProjectServiceProtocol {
    func getProjects() throws -> [Project] {
        return []
    }
    
    func getTracks(for project: Project) throws -> [Track] {
        return []
    }
    
    func getTrackDownloadStatus(_ track: Track) -> TrackDownloadStatus {
        return .downloaded
    }
    
    func downloadTrack(_ track: Track) -> AnyPublisher<URL, Error> {
        let url = URL(fileURLWithPath: "")
        return Future<URL, Error> { $0(.success(url)) }.eraseToAnyPublisher()
    }
    
    func evictTrack(_ track: Track) -> AnyPublisher<URL, Error> {
        let url = URL(fileURLWithPath: "")
        return Future<URL, Error> { $0(.success(url)) }.eraseToAnyPublisher()
    }
}

fileprivate struct PreviewNoteService: NoteServiceProtocol {
    let note = Note(id: "123", timestamp: 0, text: "This is a note")
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error> {
        return Future<[Note], Error> { $0(.success([self.note])) }.eraseToAnyPublisher()
    }
    
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error> {
        return Future<Note, Error> { $0(.success(self.note)) }.eraseToAnyPublisher()
    }
    
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { $0(.success(())) }.eraseToAnyPublisher()
    }
    
    func deleteNotes(_ notes: [Note]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { $0(.success(())) }.eraseToAnyPublisher()
    }
}
