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
    @State private var showOnboarding = false
    
    var body: some View {
        currentView
            .navigationBarTitle("Projects")
            .navigationBarItems(leading: infoButton, trailing: refreshButton)
            .onAppear(perform: viewModel.fetchProjects)
    }
    
    private var currentView: some View {
        switch viewModel.currentState {
        case .empty:
            return AnyView(createMessageView())
        default:
            return AnyView(createListView())
        }
    }
    
    private var refreshButton: some View {
        let isLoading = viewModel.currentState == .loading
        let systemName = isLoading ? SFIcon.LOADING : SFIcon.REFRESH
        return ImageButton(systemName: systemName, action: viewModel.fetchProjects)
    }
    
    private var infoButton: some View {
        ImageButton(systemName: SFIcon.INFO, action: {
            self.showOnboarding = true
        })
        .sheet(isPresented: $showOnboarding, onDismiss: {
            self.showOnboarding = false
        }) {
            OnboardingView() {
                self.showOnboarding = false
            }
        }
    }
    
    private func createListView() -> some View {
        List(viewModel.projects, id: \.id) { project in
            NavigationLink(destination: self.viewModel.createProjectView(for: project)) {
                Text(project.title)
            }
        }
    }
    
    private func createMessageView() -> some View {
        EmptyListView(
            title: "No Projects",
            systemImageName: SFIcon.EMPTY_LIST,
            description: "To get started, create a project folder in the MixNotes folder in your iCloud drive and upload a track"
        )
    }
}

struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewProjectsView()
    }
}
