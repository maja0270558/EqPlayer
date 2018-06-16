//
//  +EQSPTAudioStreamingControllerExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol StreamableController {
    func startPlayer(withClientId: String,
                     audioController: SPTCoreAudioController?,
                     allowCaching: Bool)

    func loginPlayer(withAccessToken: String)

    func playURI(uri: String,
                 startingPosition: TimeInterval,
                 callback: @escaping SPTErrorableOperationCallback)
    func getMetadata() -> SPTPlaybackMetadata
    func seekTo(_ position: TimeInterval)
    func setPlaying(_ isPlay: Bool, callback: @escaping SPTErrorableOperationCallback)
}

extension StreamableController {
    func seekTo(_: TimeInterval) {}

    func getMetadata() -> SPTPlaybackMetadata {
        return SPTPlaybackMetadata(prevTrack: nil, currentTrack: nil, nextTrack: nil)!
    }

    func setPlaying(_: Bool, callback _: @escaping SPTErrorableOperationCallback) {}

    func playURI(uri _: String, startingPosition _: TimeInterval, callback _: @escaping (Error?) -> Void) {}

    func startPlayer(withClientId _: String,
                     audioController _: SPTCoreAudioController?,
                     allowCaching _: Bool) {}

    func loginPlayer(withAccessToken _: String) {}
}

extension SPTAudioStreamingController: StreamableController {
    func seekTo(_ position: TimeInterval) {
        seek(to: position, callback: nil)
    }

    func getMetadata() -> SPTPlaybackMetadata {
        return metadata
    }

    func setPlaying(_ isPlay: Bool, callback: @escaping SPTErrorableOperationCallback) {
        setIsPlaying(isPlay, callback: callback)
    }

    func playURI(uri: String, startingPosition: TimeInterval, callback: @escaping (Error?) -> Void) {
        playSpotifyURI(uri, startingWith: 0,
                       startingWithPosition: startingPosition,
                       callback: callback)
    }

    func startPlayer(withClientId: String,
                     audioController: SPTCoreAudioController?,
                     allowCaching: Bool) {
        try? start(withClientId: withClientId,
                   audioController: audioController,
                   allowCaching: allowCaching)
    }

    func loginPlayer(withAccessToken: String) {
        login(withAccessToken: withAccessToken)
    }
}
