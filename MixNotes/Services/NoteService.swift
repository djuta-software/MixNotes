import Combine

protocol NoteServiceProtocol {
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error>
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error>
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error>
    func deleteNotes(_ notes: [Note]) -> AnyPublisher<Void, Error>
}

struct NoteService: NoteServiceProtocol {
    let noteRepository: NoteRepositoryProtocol
    init(noteRepository: NoteRepositoryProtocol) {
        self.noteRepository = noteRepository
    }
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error> {
        return noteRepository.getNotes(for: track)
    }
    
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error> {
        return noteRepository.addNote(for: track, at: timestamp, text: text)
    }
    
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error> {
        return noteRepository.deleteNote(note)
    }
    
    func deleteNotes(_ notes: [Note]) -> AnyPublisher<Void, Error> {
        return noteRepository.deleteNotes(notes)
    }
}
