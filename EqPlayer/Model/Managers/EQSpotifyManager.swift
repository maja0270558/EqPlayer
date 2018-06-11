//
//  EQSpotifyManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import MediaPlayer
import SafariServices

protocol EQSpotifyManagerDelegate: class {
    func didChangeTrack(track: SPTPlaybackTrack)
    func didChangePlaybackStatus(isPlaying: Bool)
    func didPositionChange(position: TimeInterval)
}

enum EQPlayingType {
    case project
    case preview
    case none
}

class EQSpotifyManager: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, SPTCoreAudioControllerDelegate {
    static let shard: EQSpotifyManager = EQSpotifyManager()
    weak var delegate: EQSpotifyManagerDelegate?
    var currentSetting = [Double]()
    let durationObseve = EQPlayerDurationObseveModel()
    var obsever: NSKeyValueObservation?
    let userDefaults = UserDefaults.standard
    var player = SPTAudioStreamingController.sharedInstance()
    var auth = SPTAuth.defaultInstance()
    var authViewController: SFSafariViewController?
    var loginURL: URL?
    var coreAudioController = EQSpotifyCoreAudioController()
    var currentPlayIndex: Int = 0
    var playbackBackgroundTask = UIBackgroundTaskIdentifier()
    var eqSettingForPreview: [Float] = Array(repeating: 0, count: 15)
    var currentPlayingType: EQPlayingType = .none
    var previousPreviewURLString: String = ""
    private var trackList: [String] = [String]()

    func setupAuth() {
        auth?.clientID = EQSpotifyClientInfo.clientID.rawValue
        auth?.redirectURL = URL(string: EQSpotifyClientInfo.redirectURL.rawValue)!
        auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserReadEmailScope, SPTAuthUserReadPrivateScope]
        auth?.sessionUserDefaultsKey = EQSpotifyClientInfo.sessionKey.rawValue
        loginURL = auth?.spotifyWebAuthenticationURL()
        NotificationCenter.default.addObserver(self, selector: #selector(EQSpotifyManager.updateAfterFirstLogin), name: NSNotification.Name(rawValue: "loginSuccessfull"), object: nil)
    }

    @objc func updateAfterFirstLogin() {
        guard let session = auth?.session else {
            fatalError("session nil")
        }
        initializePlayer(authSession: session)
    }

    func initializePlayer(authSession: SPTSession) {
        guard let userAuth = auth else {
            return
        }
        player!.playbackDelegate = self
        player!.delegate = self
        do {
            try player?.start(withClientId: userAuth.clientID, audioController: coreAudioController, allowCaching: false)
        } catch {
            print("error")
        }
        player!.login(withAccessToken: authSession.accessToken)
    }

    func popLoginViewController() {
        authViewController = SFSafariViewController(url: loginURL!)
        UIApplication.shared.keyWindow?.rootViewController?.present(authViewController!, animated: true, completion: nil)
    }

    func login() {
        if let session = auth?.session {
            if (auth?.session.isValid())! {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
            } else {
                popLoginViewController()
            }
        } else {
            popLoginViewController()
        }
    }

    func getSession() -> Data? {
        let session = UserDefaults.standard.value(forKey: EQSpotifyClientInfo.sessionKey.rawValue)
        guard let data = session as? Data else {
            return nil
        }
        return data
    }
}

extension EQSpotifyManager {
    func setupLockScreen() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(skip))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(previous))
        MPNowPlayingInfoCenter.default().nowPlayingInfo = [MPMediaItemPropertyTitle: "TESTING"]
    }

    func playOrPause(isPlay: Bool, completion: @escaping () -> Void) {
        switch currentPlayingType {
        case .preview:
            playFromLastDuration()
        case .project:
            player?.setIsPlaying(isPlay, callback: { error in
                if error != nil {
                    print(error.debugDescription + "----->")
                    return
                }
                completion()
            })
        default:
            break
        }
    }

    func playPreview(uri: String, duration: Double, callback: @escaping () -> Void = { return }) {
        currentPlayingType = .preview
        player?.playSpotifyURI(uri, startingWith: 0, startingWithPosition: duration / 2, callback: { error in
            if error != nil {
                print(error.debugDescription + "----->")
                return
            }
            callback()
        })
    }

    func playFirstTrack() {
        currentPlayingType = .project
        currentPlayIndex = 0
        playTrack()
    }

    func playTrack() {
        currentPlayingType = .project
        player?.playSpotifyURI(trackList[self.currentPlayIndex], startingWith: 0, startingWithPosition: 0, callback: { error in
            if error != nil {
                print(error.debugDescription + "----->")
                return
            }
        })
    }

    func playFromLastDuration() {
        if currentPlayingType != .project {
            currentPlayingType = .project
            if trackList.count > 0 {
                player?.playSpotifyURI(durationObseve.currentPlayingURI, startingWith: 0, startingWithPosition: durationObseve.currentDuration, callback: { error in
                    if error != nil {
                        print(error.debugDescription + "----->")
                        return
                    }
                })
            } else {
                playOrPause(isPlay: false) {
                }
            }
        }
    }

    func checkIsModifyCurrentModel() {
    }

    @objc func skip() {
        currentPlayIndex += 1
        if currentPlayIndex >= trackList.count {
            currentPlayIndex = trackList.count - 1
            return
        }
        playTrack()
    }

    @objc func previous() {
        currentPlayIndex -= 1
        if currentPlayIndex < 0 {
            currentPlayIndex = 0
            return
        }
        playTrack()
    }

    func queuePlaylist(playlistURI: [String]) {
        trackList = playlistURI
    }

    func setGain(value: Float, atBand: UInt32) {
        coreAudioController.setGain(value: value, forBandAt: atBand)
    }

    func setGain(withModel model: EQProjectModel) {
        let bandValues = Array(model.eqSetting).map {
            return Float($0)
        }
        for index in 0 ..< bandValues.count {
            coreAudioController.setGain(value: bandValues[index], forBandAt: UInt32(index))
        }
    }
  func setGain(setting: [Double]) {
    for index in 0 ..< setting.count {
      coreAudioController.setGain(value: Float(setting[index]), forBandAt: UInt32(index))
    }
  }
    func resetPreviewURL() {
        previousPreviewURLString = ""
    }
}

extension EQSpotifyManager {
    func audioStreamingDidLogin(_: SPTAudioStreamingController!) {
        AppDelegate.shard?.switchToMainStoryBoard()
    }

    func audioStreamingDidLosePermission(forPlayback _: SPTAudioStreamingController!) {
        print("lose")
    }

    func audioStreamingDidEncounterTemporaryConnectionError(_: SPTAudioStreamingController!) {
        print("encount")
    }

    func audioStreaming(_: SPTAudioStreamingController!, didStartPlayingTrack _: String!) {
        print("start")
    }

    func audioStreaming(_: SPTAudioStreamingController!, didStopPlayingTrack _: String!) {
        skip()
    }

    func audioStreaming(_: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        guard let currentTrack = metadata.currentTrack else {
            return
        }
        delegate?.didChangeTrack(track: currentTrack)
    }

    func audioStreaming(_: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        delegate?.didChangePlaybackStatus(isPlaying: isPlaying)
    }

    func audioStreaming(_: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        delegate?.didPositionChange(position: position)
    }
}
