//
//  Player.swift
//  MixNotes
//
//  Created by Deven Juta on 2020-06-24.
//  Copyright © 2020 Deven Juta. All rights reserved.
//

import SwiftUI

struct Player: View {
    
    enum PrimaryButtonState: String {
        case download
        case play
        case pause
        case error
        case downloading
        case loading
    }
    
    private let SKIP_SECONDS = 10.0

    @EnvironmentObject var globalPlayerService: GlobalPlayerService
    
    @Binding var track: Track
    @Binding var downloadState: TrackViewModel.DownloadState
    let downloadTrack: () -> Void

    var body: some View {
        VStack {
            slider
            HStack {
                CircularImageButton(
                    systemName: SFIcon.SKIP_BACKWARD,
                    diameter: 50,
                    backgroundColor: Color.orange,
                    action: skipBackward
                )
                
                CircularImageButton(
                    systemName: primaryButtonImage,
                    diameter: 75,
                    backgroundColor: Color.orange,
                    action: primaryButtonAction ?? {}
                )
                .disabled(primaryButtonAction == nil)
                
                CircularImageButton(
                    systemName: SFIcon.SKIP_FORWARD,
                    diameter: 50,
                    backgroundColor: Color.orange,
                    action: skipForward
                )
            }
        }
        .onDisappear(perform: onDisappear)
    }
    
    private var slider: some View {
        Slider(
            value: $globalPlayerService.currentTime,
            in: 0...globalPlayerService.duration
        ) { self.globalPlayerService.isScrubbing = $0 }
    }
    
    private func skipBackward() {
        globalPlayerService.skipBackward(numberOfSeconds: SKIP_SECONDS)
    }
    
    private func skipForward() {
        globalPlayerService.skipForward(numberOfSeconds: SKIP_SECONDS)
    }
    
    private func playTrack() {
        if(globalPlayerService.currentTrack != track) {
            globalPlayerService.loadAndPlay(track)
        } else {
            globalPlayerService.togglePlayPause()
        }
    }
    
    private func onDisappear() {
        globalPlayerService.pause()
    }
    
    private var buttonState: PrimaryButtonState {
        let shouldDownload = (
            downloadState == .error ||
            downloadState == .remote ||
            downloadState == .stale
        )
        if shouldDownload {
            return .download
        }
        if downloadState == .current {
            return globalPlayerService.isPlaying ? .pause : .play
        }
        if downloadState == .downloading {
            return .downloading
        }
        return .error
    }
    
    private var primaryButtonAction: (() -> Void)? {
        switch buttonState {
        case .download:
            return downloadTrack
        case .play, .pause:
            return playTrack
        default:
            return nil
        }
    }
    
    private var primaryButtonImage: String {
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
}

//struct Player_Previews: PreviewProvider {
//    static var previews: some View {
//        Player()
//    }
//}
