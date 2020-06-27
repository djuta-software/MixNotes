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
            HStack(alignment: .top) {
                FormattedTime(time: Double(note.timestamp))
                Spacer()
                Button(action: deleteCurrentNote) {
                    Image(systemName: SFIcon.DELETE)
                }
            }
            Spacer()
            Text(note.text)
            Spacer()
        }
        return AnyView(view)
    }
    
    private func deleteCurrentNote() {
        guard let note = currentNote else { return }
        deleteNote(note)
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
