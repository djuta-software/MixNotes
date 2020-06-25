//
//  NoteInput.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-24.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct NoteInput: View {
    
    @EnvironmentObject var globalPlayerService: GlobalPlayerService
    @State var newNote = ""
    
    let addNote: (Int, String) -> Void
    
    var body: some View {
        HStack {
            TextField("Note", text: $newNote)
                .onTapGesture(perform: globalPlayerService.pause)
                .background(Color.white)
            Button(action: addNewNote) {
                Text("Add")
            }
            .background(Color.green)
        }
    }
    
    private func addNewNote() {
        if(newNote.isEmpty) {
            return
        }
        let timestamp = Int(round(globalPlayerService.currentTime))
        addNote(timestamp, newNote)
        newNote = ""
    }
}

//struct NoteInput_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteInput()
//    }
//}
