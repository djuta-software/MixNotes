import SwiftUI

struct TrackView: View {

    @EnvironmentObject var globalPlayerService: GlobalPlayerService
    @ObservedObject var viewModel: TrackViewModel
    @State var newNote = ""
    
    var body: some View {
        VStack {
            Text(viewModel.track.title)
            Text("Version \(viewModel.track.version)")
            Text("Status: \(viewModel.downloadStatus.rawValue)")
            Button(action: viewModel.downloadTrack) {
                Text("Download")
            }
            .disabled(isDownloadingDisabled)
            
            Button(action: viewModel.evictTrack) {
                Text("Evict Track")
            }
            .disabled(isEvictingDisabled)
            
            Button(action: playTrack) {
                Text("Play")
            }
            .disabled(viewModel.downloadStatus != .current)
            
            Text("\(currentTime)")
            
            Section {            
                Text(currentNote?.text ?? "")

                TextField("Note", text: $newNote)
                    .onTapGesture(perform: globalPlayerService.pause)
                
                Button(action: addNote) {
                    Text("Add")
                }
                
                Button(action: deleteNote) {
                    Text("Delete")
                }
            }
        }
        .onAppear(perform: onAppear)
        .onDisappear(perform: onDisappear)
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
        globalPlayerService.hidePlayer()
        viewModel.checkIfTrackIsDownloaded()
        viewModel.fetchNotes()
    }
    
    func onDisappear() {
        globalPlayerService.showPlayer()
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

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView()
//    }
//}
