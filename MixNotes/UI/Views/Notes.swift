//
//  Notes.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-24.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct Notes: View {

    @EnvironmentObject var globalPlayerService: GlobalPlayerService

    @Binding var track: Track
    @Binding var notes: [Note]
    let deleteNote: (Note) -> Void
    
    var body: some View {
        guard let note = currentNote else {
            return AnyView(EmptyView())
        }
        let view = VStack(alignment: .leading) {
            HStack {
                previosButton
                HStack(alignment: .top) {
                    FormattedTime(time: Double(note.timestamp))
                    Spacer()
                    Button(action: deleteCurrentNote) {
                        Image(systemName: SFIcon.DELETE)
                    }
                }
                nextButton
            }
            Spacer()
            Text(note.text)
            Spacer()

        }
        return AnyView(view)
    }
    
    private var previosButton: some View {
        if let currentIndex = currentNoteIndex, currentIndex > 0 {
            return AnyView(ImageButton(systemName: SFIcon.PREVIOUS_NOTE, action: goToPreviousNote))
        }
        return AnyView(EmptyView())
    }
    
    private var nextButton: some View {
        if let currentIndex = currentNoteIndex, currentIndex < notes.count - 1 {
            return AnyView(ImageButton(systemName: SFIcon.NEXT_NOTE, action: goToNextNote))
        }
        return AnyView(EmptyView())
    }
    
    private func deleteCurrentNote() {
        guard let note = currentNote else { return }
        deleteNote(note)
    }
    
    private func goToPreviousNote() {
        guard let currentIndex = currentNoteIndex, currentIndex > 0 else { return }
        let previousNote = notes[currentIndex - 1]
        globalPlayerService.setTime(seconds: previousNote.timestamp)
    }
    
    private func goToNextNote() {
        let lastIndex = notes.count - 1
        guard let currentIndex = currentNoteIndex, currentIndex < lastIndex  else { return }
        let currentNote = notes[currentIndex + 1]
        globalPlayerService.setTime(seconds: currentNote.timestamp)
    }
    
    private var currentNoteIndex: Int? {
        guard let note = currentNote else { return nil }
        return notes.firstIndex { $0.id == note.id }
    }
    
    private var currentNote: Note? {
        if(globalPlayerService.currentTrack != track) {
            return nil
        }
        return notes.last {
            $0.timestamp <= Int(round(globalPlayerService.currentTime))
        }
    }
}

//struct Notes_Previews: PreviewProvider {
//    static var previews: some View {
//        Notes()
//    }
//}
