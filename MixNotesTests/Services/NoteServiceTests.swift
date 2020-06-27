import XCTest
import Combine
@testable import MixNotes

class NoteServiceTests: XCTestCase {

    var noteRepository: MockNoteRepository?
    var noteService: NoteService?
    
    let testTrack = Track(
        id: "Project 1-Track 1",
        title: "Track 1",
        lastModified: Date(),
        url: URL(fileURLWithPath: "Project 1/Track 1")
    )

    override func setUp() {
        noteRepository = MockNoteRepository()
        noteService = NoteService(noteRepository: noteRepository!)

        for n in 1...3 {
            let timestamp = n * 10
            _ = noteRepository?.addNote(for: testTrack, at: timestamp, text: "This is note \(n)")
        }
    }
    
    func testGetNotes() {
        let expectation = XCTestExpectation(description: "Get notes should succeed")
        let publisher = noteService!.getNotes(for: testTrack)
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) { notes in
            XCTAssert(notes.count == 3)
            for (index, note) in notes.enumerated() {
                let n = index + 1
                XCTAssert(note.text == "This is note \(n)")
                XCTAssert(note.timestamp == n * 10)
            }
        }
    }
    
    func testGetNotesErrors() {
        noteRepository?.isInErrorState = true
        let expectation = XCTestExpectation(description: "Get notes should fail")
        let publisher = noteService!.getNotes(for: testTrack)
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
    
    func testAddNote() {
        let expectation = XCTestExpectation(description: "Add notes should succeed")
        let publisher = noteService!.addNote(for: testTrack, at: 27, text: "This is a new note")
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) {
            XCTAssert($0.text == "This is a new note")
            XCTAssert($0.timestamp == 27)
        }
    }
    
    func testAddNoteErrors() {
        noteRepository?.isInErrorState = true
        let expectation = XCTestExpectation(description: "Add note should fail")
        let publisher = noteService!.addNote(for: testTrack, at: 27, text: "This is a new note")
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
    
    func testDeleteNote() {
        let expectation = XCTestExpectation(description: "Delete note should succeed")
        var notes: [Note] = []
        _ = noteService?.getNotes(for: testTrack)
            .sink(receiveCompletion: { _ in }, receiveValue: { notes = $0 })
        let lastNote = notes.last!
        _ = noteService?.deleteNote(lastNote)
        let publisher = noteService!.getNotes(for: testTrack)
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) { newNotes in
            let note = newNotes.first { $0.id == lastNote.id }
            XCTAssertNil(note)
        }
    }
    
    func testDeleteNoteErrors() {
        let expectation = XCTestExpectation(description: "Delete note should fail")
        var notes: [Note] = []
        _ = noteService?.getNotes(for: testTrack)
            .sink(receiveCompletion: { _ in }, receiveValue: { notes = $0 })
        let lastNote = notes.last!
        noteRepository?.isInErrorState = true
        let publisher = noteService!.deleteNote(lastNote)
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
    
    
    func testDeleteNotes() {
        let expectation = XCTestExpectation(description: "Delete notes should succeed")
        var notes: [Note] = []
        _ = noteService?.getNotes(for: testTrack)
            .sink(receiveCompletion: { _ in }, receiveValue: { notes = $0 })
        XCTAssert(notes.count == 3)
        _ = noteService!.deleteNotes(notes)
        let publisher = noteService!.getNotes(for: testTrack)
        MixNotes_XCTAssertPublisherFinishes(
            expectation: expectation,
            publisher: publisher
        ) { XCTAssert($0.isEmpty) }
    }
    
    func testDeleteNotesErrors() {
        let expectation = XCTestExpectation(description: "Delete notes should fail")
        var notes: [Note] = []
        _ = noteService?.getNotes(for: testTrack)
            .sink(receiveCompletion: { _ in }, receiveValue: { notes = $0 })
        noteRepository?.isInErrorState = true
        let publisher = noteService!.deleteNotes(notes)
        MixNotes_XCTAssertPublisherErrors(
            expectation: expectation,
            publisher: publisher
        )
    }
}
