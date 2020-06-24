import SwiftUI

struct ProjectView: View {
    @ObservedObject var viewModel: ProjectViewModel

    var body: some View {
        currentView
            .navigationBarTitle(viewModel.project.title)
            .navigationBarItems(trailing: refreshButton)
            .onAppear(perform: viewModel.fetchTracks)
    }
    
    var currentView: some View {
        switch viewModel.currentState {
        case .empty:
            return AnyView(createMessageView())
        default:
            return AnyView(createListView())
        }
    }
    
    var refreshButton: some View {
        let isLoading = viewModel.currentState == .loading
        let systemName = isLoading ? SFIcon.LOADING : SFIcon.REFRESH
        return ImageButton(systemName: systemName, action: viewModel.fetchTracks)
    }
    
    private func createListView() -> some View {
        List(viewModel.tracks, id: \.id) { track in
            NavigationLink(destination: self.viewModel.createTrackView(for: track)) {
                Text(track.title)
            }
        }
    }
    
    private func createMessageView() -> some View {
        EmptyListView(
            title: "No Tracks",
            systemImageName: SFIcon.EMPTY_LIST,
            description: "To get started upload a track to the \"\(viewModel.project.title)\" folder in the MixNotes folder on your iCloud drive"
        )
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewProjectView()
    }
}
