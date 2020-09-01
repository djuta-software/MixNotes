import Foundation
import CloudKit
import Combine
import CoreData

protocol NoteRepositoryProtocol {
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error>
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error>
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error>
    func deleteNotes(_ notes: [Note]) -> AnyPublisher<Void, Error>
}

enum NoteRepositoryError: Error {
    case writeError
}

struct NoteRepository: NoteRepositoryProtocol {
    let container: NSPersistentCloudKitContainer
    let database = CKContainer(identifier: "iCloud.PAL").privateCloudDatabase
    func getNotes(for track: Track) -> AnyPublisher<[Note], Error> {

        let pred = NSPredicate(format: "trackId == %@", track.id)
        let sort = NSSortDescriptor(key: "timestamp", ascending: true)
        let query = CKQuery(recordType: "Notes", predicate: pred)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["text", "timestamp"]
        operation.resultsLimit = 50
        
        var notes = [Note]()
        operation.recordFetchedBlock = { record in
            notes.append(Note(from: record))
        }
        return Future<[Note], Error> { promise in
            operation.queryCompletionBlock = { (_, queryError) in
                if let error = queryError {
                    promise(.failure(error))
                    return
                }
                promise(.success(notes))
            }
            self.database.add(operation)
        }
        .eraseToAnyPublisher()
    }
    
    func addNote(for track: Track, at timestamp: Int, text: String) -> AnyPublisher<Note, Error> {
        let newRecord = CKRecord(recordType: "Notes")
        newRecord.setValue(timestamp, forKey: "timestamp")
        newRecord.setValue(text, forKey: "text")
        newRecord.setValue(track.id, forKey: "trackId")
        return Future<Note, Error> { promise in
            self.database.save(newRecord) { (newRecord, writeError) in
                if let error = writeError {
                    promise(.failure(error))
                    return
                }
                guard let record = newRecord else {
                    promise(.failure(NoteRepositoryError.writeError))
                    return
                }
                let note = Note(from: record)
                promise(.success(note))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNote(_ note: Note) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let recordID = CKRecord.ID(recordName: note.id)
            self.database.delete(withRecordID: recordID) { (_, deleteError) in
                if let error = deleteError {
                    promise(.failure(error))
                    return
                }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteNotes(_ notes: [Note]) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            let recordIDs = notes.map { CKRecord.ID(recordName: $0.id) }
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: recordIDs)
            operation.modifyRecordsCompletionBlock = { (_, _, deleteError) in
                if let error = deleteError {
                    promise(.failure(error))
                    return
                }
                promise(.success(()))
            }
            self.database.add(operation)
        }
        .eraseToAnyPublisher()
    }
}

fileprivate extension Note {
    init(from record: CKRecord) {
        id = record.recordID.recordName
        text = record.value(forKey: "text") as! String
        timestamp = record.value(forKey: "timestamp") as! Int
    }
}
