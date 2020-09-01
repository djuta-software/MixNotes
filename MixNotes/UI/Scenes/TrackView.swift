import SwiftUI

struct TrackView: View {
    
    enum ButtonState: String {
        case download
        case play
        case pause
        case error
        case downloading
        case loading
    }
    
    @EnvironmentObject var globalPlayerService: GlobalPlayerService
    @ObservedObject var viewModel: TrackViewModel
    @State var newNote = ""
    
    var body: some View {
        VStack {
            trackData
            Spacer().frame(maxWidth: .infinity)
            notes
            Spacer().frame(maxWidth: .infinity)
            noteInput
            player
        }
        .navigationBarTitle(viewModel.track.title)
        .navigationBarItems(trailing: contextMenu)
        .onAppear(perform: onAppear)
    }
    
    private var contextMenu: some View {
        Image(systemName: SFIcon.CONTEXT_MENU)
            .contextMenu {
                Button(action: viewModel.evictTrack) {
                    Text("Remove Download")
                }
                .disabled(
                    viewModel.downloadState != .current &&
                    viewModel.downloadState != .stale
                )
                
                Button(action: viewModel.deleteNotes) {
                    Text("Remove all notes")
                }
            }
    }
    
    private var trackData: some View {
        var displayDate = ""
        if let date = viewModel.track.lastModified {
            displayDate = DateTimeUtils.formatDate(date)
        }
        return Text("Last Modified: \(displayDate)")
        .padding()
        .background(Color.orange)
    }
    
    private var notes: some View {
        Notes(track: $viewModel.track, notes: $viewModel.notes, deleteNote: viewModel.deleteNote)
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: 200
        )
        .padding()
        .background(Color.gray)
    }
    
    private var noteInput: some View {
        NoteInput(addNote: viewModel.addNote)
        .padding()
        .background(Color.blue)
    }
    
    private var player: some View {
        Player(
            track: $viewModel.track,
            downloadState: $viewModel.downloadState,
            downloadTrack: viewModel.downloadTrack
        )
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: 300
        )
        .background(Color.pink)
    }
    
    private func onAppear() {
        viewModel.checkIfTrackIsDownloaded()
        viewModel.fetchNotes()
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewTrackView()
    }
}
