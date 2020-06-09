import Foundation
import Combine

enum MockNoteRepositoryError: Error {
    case addError, getError, deleteError
}

class MockNoteRepository: NoteRepositoryProtocol {
   
    var notes: [String: [Note]] = [:]
    var isInErrorState = false
    
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error> {
        let trackNotes = notes[track.id] ?? []
        return Future<[Note], Error> { promise in
            if(self.isInErrorState) {
                promise(.failure(MockNoteRepositoryError.getError))
                return
            }
            promise(.success(trackNotes))
        }
        .eraseToAnyPublisher()  
    }
    
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error> {
        let note = Note(id: UUID().uuidString, timestamp: timestamp, text: text)
        if notes[track.id] == nil {
            notes[track.id] = []
        }
        notes[track.id]?.append(note)
        return Future<Note, Error> { promise in
            if(self.isInErrorState) {
                promise(.failure(MockNoteRepositoryError.addError))
                return
            }
            promise(.success(note))
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error> {
        for (key, _) in notes {
            notes[key]?.removeAll { $0.id == note.id }
        }
        return Future<Void, Error> { promise in
            if(self.isInErrorState) {
                promise(.failure(MockNoteRepositoryError.addError))
                return
            }
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
