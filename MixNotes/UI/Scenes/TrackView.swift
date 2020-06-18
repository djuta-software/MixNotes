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
    @State private var offsetValue: CGFloat = 0.0
    @State var newNote = ""
    let skipSeconds = 10.0
    
    var body: some View {
        VStack {
            trackData
            Spacer().frame(maxWidth: .infinity)
            notes
            Text(viewModel.downloadStatus.rawValue)
            Spacer().frame(maxWidth: .infinity)
            noteInput
            player
        }
        .navigationBarTitle(viewModel.track.title)
        .navigationBarItems(trailing: contextMenu)
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
    }
    
    var contextMenu: some View {
        Image(systemName: SFIcon.CONTEXT_MENU)
            .contextMenu {
                removeAllNotes
                removeDownloadButton
            }
    }
    
    var removeDownloadButton: some View {
        Button(action: viewModel.evictTrack) {
            Text("Remove Download")
        }
        .disabled(
            viewModel.downloadStatus != .current &&
            viewModel.downloadStatus != .stale
        )
    }
    
    var removeAllNotes: some View {
        Button(action: viewModel.deleteNotes) {
            Text("Remove all notes")
        }
    }
    
    var notes: some View {
        guard let note = currentNote else {
            return AnyView(Text("Nothing"))
        }
        let view = VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Text("\(note.timestamp)")
                Spacer()
                Button(action: deleteNote) {
                    Image(systemName: SFIcon.DELETE)
                }
            }
            Spacer()
            Text(note.text)
            Spacer()
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: 200
        )
        .padding()
        .background(Color.gray)
        return AnyView(view)
    }
    
    var trackData: some View {
        HStack {
            Text(viewModel.track.title)
                .font(.title)
            Spacer()
            Text("Version \(viewModel.track.version)")
        }
        .padding()
        .background(Color.orange)
    }
    
    var noteInput: some View {
        HStack {
            Text("\(globalPlayerService.currentTime)")
            TextField("Note", text: $newNote)
                .onTapGesture(perform: globalPlayerService.pause)
                .background(Color.white)
            Button(action: addNote) {
                Text("Add")
            }
            .background(Color.green)
        }
        .padding()
        .background(Color.blue)
    }
    
    var player: some View {
        VStack {
            HStack {
                Button(action: skipBackward) {
                    Image(systemName: SFIcon.SKIP_BACKWARD)
                        .frame(width: 50, height: 50)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                
                Button(action: onButtonClick) {
                    Image(systemName: buttonIcon)
                        .frame(width: 75, height: 75)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
                .disabled(viewModel.downloadStatus == .evicting)
                .disabled(viewModel.downloadStatus == .downloading)
                
                Button(action: skipForward) {
                    Image(systemName: SFIcon.SKIP_FORWARD)
                        .frame(width: 50, height: 50)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: 200
        )
        .background(Color.pink)
    }
    
    func skipBackward() {
        globalPlayerService.skipBackward(numberOfSeconds: skipSeconds)
    }

    func skipForward() {
        globalPlayerService.skipForward(numberOfSeconds: skipSeconds)
    }
    
    
    var buttonState: ButtonState {
        let shouldDownload = (
            viewModel.downloadStatus == .error ||
            viewModel.downloadStatus == .remote ||
            viewModel.downloadStatus == .stale
        )
        if shouldDownload {
            return .download
        }
        if viewModel.downloadStatus == .current {
            return globalPlayerService.isPlaying ? .pause : .play
        }
        if viewModel.downloadStatus == .downloading {
            return .downloading
        }
        return .error
    }
    
    var onButtonClick: () -> Void {
        switch buttonState {
        case .download:
            return viewModel.downloadTrack
        case .play, .pause:
            return playTrack
        default:
            return {}
        }
    }
    
    var buttonIcon: String {
        switch buttonState {
        case .download:
            return SFIcon.DOWNLOAD
        case .downloading:
            return SFIcon.DOWNLOADING
        case .error:
            return SFIcon.ERROR
        case .loading:
            return SFIcon.LOADING
        case .pause:
            return SFIcon.PAUSE
        case .play:
            return SFIcon.PLAY
        }
    }
    
    func playTrack() {
        if(globalPlayerService.currentTrack != viewModel.track) {
            globalPlayerService.loadAndPlay(viewModel.track)
        } else {
            globalPlayerService.togglePlayPause()
        }
    }
    
    func addNote() {
        if(newNote.isEmpty) {
            return
        }
        let timestamp = globalPlayerService.currentTime
        viewModel.addNote(at: timestamp, text: newNote)
        newNote = ""
    }
    
    func deleteNote() {
        guard let note = currentNote else { return }
        viewModel.deleteNote(note)
    }
    
    func onAppear() {
        viewModel.checkIfTrackIsDownloaded()
        viewModel.fetchNotes()
    }
    
    func onDisappear() {
        globalPlayerService.pause()
    }
    
    var isDownloadingDisabled: Bool {
        viewModel.downloadStatus == .current ||
        viewModel.downloadStatus == .downloading ||
        viewModel.downloadStatus == .evicting
    }
    
    var isEvictingDisabled: Bool {
        viewModel.downloadStatus == .downloading ||
        viewModel.downloadStatus == .evicting ||
        viewModel.downloadStatus == .remote
    }
    
    var currentTime: Int {
        return globalPlayerService.currentTime
    }
    
    var currentNote: Note? {
        if(globalPlayerService.currentTrack != viewModel.track) {
            return nil
        }
        return viewModel.notes.last {
            $0.timestamp <= globalPlayerService.currentTime
        }
    }
}

struct TrackView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewUtils.createPreviewTrackView()
    }
}
