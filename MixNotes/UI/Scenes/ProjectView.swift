import SwiftUI

struct ProjectView: View {
    @ObservedObject var viewModel: ProjectViewModel

    var body: some View {
        list
        .navigationBarTitle(viewModel.project.title)
        .navigationBarItems(trailing: refreshButton)
        .onAppear(perform: viewModel.fetchTracks)
    }
    
    var refreshButton: some View {
        Button(action: viewModel.fetchTracks) {
            Image(systemName: SFIcon.REFRESH)
        }
    }
    
    var list: some View {
        if(viewModel.tracks.isEmpty) {
            let view = EmptyListView(
                title: "No Tracks",
                systemImageName: SFIcon.EMPTY_LIST,
                description: "To get started upload a track to the \"\(viewModel.project.title)\" folder in the MixNotes folder on your iCloud drive")
            return AnyView(view)
        }
        let view = List(viewModel.tracks, id: \.id) { track in
            NavigationLink(destination: self.viewModel.createTrackView(for: track)) {
                Text(track.title)
            }
        }
        return AnyView(view)
    }
}

struct ProjectView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewProjectView()
    }
}
