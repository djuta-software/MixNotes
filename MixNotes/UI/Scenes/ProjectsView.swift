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
        List(viewModel.projects, id: \.id) { project in
            NavigationLink(destination: self.viewModel.createProjectView(for: project)) {
                Text(project.title)
            }
        }
        .navigationBarTitle("Projects")
        .onAppear(perform: viewModel.fetchProjects)
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewProjectsView()
    }
}
