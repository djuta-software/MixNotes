import SwiftUI

struct ProjectView: View {
    @ObservedObject var viewModel: ProjectViewModel

    var body: some View {
        list
        .navigationBarTitle(viewModel.project.title)
        .onAppear(perform: viewModel.fetchTracks)
    }
    
    var list: some View {
        if(viewModel.tracks.isEmpty) {
            return AnyView(EmptyView())
        }
        let list = List(viewModel.tracks, id: \.id) { track in
            NavigationLink(destination: self.viewModel.createTrackView(for: track)) {
                Text(track.title)
            }
        }
        return AnyView(list)
    }
}

//struct ProjectView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectView()
//    }
//}
