import SwiftUI

struct GlobalPlayerView: View {
    
    @EnvironmentObject var globalPlayerService: GlobalPlayerService
    
    var body: some View {
        
        if(!globalPlayerService.isVisible || globalPlayerService.currentTrack == nil) {
            return AnyView(EmptyView())
        }

        let view = HStack {
            Text(globalPlayerService.currentTrack?.title ?? "")
            Text("Current Time: \(globalPlayerService.currentTime)")
            Button(action: globalPlayerService.togglePlayPause) {
                Image(systemName: currentPlayIcon)
            }
            .disabled(globalPlayerService.state == .loading)
            .disabled(globalPlayerService.state == .stopped)
        }
        .frame(
            minWidth: 0,
            maxWidth: .infinity,
            minHeight: 0,
            maxHeight: CGFloat(UIConstants.PLAYER_HEIGHT)
        )
        .background(Color.red)
        
        return AnyView(view)
    }
    
    private var currentPlayIcon: String {
        switch globalPlayerService.state {
        case .playing:
            return SFIcon.PAUSE
        case .loading:
            return SFIcon.LOADING
        default:
            return SFIcon.PLAY
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        GlobalPlayerView()
    }
}
