//
//  ProjectsView.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-04-28.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct ProjectsView: View {
    @ObservedObject var viewModel: ProjectsViewModel
    var body: some View {
        list
            .navigationBarTitle("Projects")
            .navigationBarItems(leading: infoButton, trailing: refreshButton)
            .onAppear(perform: viewModel.fetchProjects)
    }
    
    var infoButton: some View {
        Button(action: {}) {
            Image(systemName: SFIcon.INFO)
        }
    }
    
    var list: some View {
        if(viewModel.projects.isEmpty) {
            let view = EmptyListView(
                title: "No Projects",
                systemImageName: SFIcon.EMPTY_LIST,
                description: "To get started, create a project folder in the MixNotes folder in your iCloud drive and upload a track"
            )
            return AnyView(view)
        }
        let view = List(viewModel.projects, id: \.id) { project in
            NavigationLink(destination: self.viewModel.createProjectView(for: project)) {
                Text(project.title)
            }
        }
        return AnyView(view)
    }
    
    var refreshButton: some View {
        Button(action: viewModel.fetchProjects) {
            Image(systemName: SFIcon.REFRESH)
        }
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewProjectsView()
    }
}
