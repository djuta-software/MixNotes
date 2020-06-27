//
//  ContentView.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-04-28.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct ContentView: View {

    let globalMessageService = GlobalMessageService()
    let globalPlayerService = GlobalPlayerService(player: PlayerService())
    
    var body: some View {
        ZStack {
            VStack {
                NavigationView {
                    mainView
                }
                
            }
            GlobalMessageView(globalMessageService: globalMessageService)
        }
        .environmentObject(globalPlayerService)
    }
    
    private var mainView: some View {
        do {
            let fileService = try FileService()
            let noteService = NoteService(noteRepository: NoteRepository())
            let projectService = ProjectService(fileService: fileService)
            let viewModel = ProjectsViewModel(
                projectService: projectService,
                noteService: noteService,
                globalMessageService: globalMessageService
            )
            let projectsView = ProjectsView(viewModel: viewModel)
            return AnyView(projectsView)
        } catch {
            globalMessageService.setErrorMessage("Somethings wrong :(")
            return AnyView(EmptyView())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
