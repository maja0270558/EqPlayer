//
//  EQSpotifyManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import SafariServices
import MediaPlayer

protocol EQSpotifyManagerDelegate: class {
  func didChangeTrack(track: SPTPlaybackTrack)
  func didChangePlaybackStatus(isPlaying: Bool)
  func didPositionChange(position: TimeInterval)
}

class EQSpotifyManager: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, SPTCoreAudioControllerDelegate {
  static let shard: EQSpotifyManager = EQSpotifyManager()
  weak var delegate: EQSpotifyManagerDelegate?
  var obsever: NSKeyValueObservation?
  let userDefaults = UserDefaults.standard
  var player = SPTAudioStreamingController.sharedInstance()
  var auth = SPTAuth.defaultInstance()
  var authViewController: SFSafariViewController?
  var loginURL: URL?
  var coreAudioController = EQSpotifyCoreAudioController()
  var currentPlayIndex:Int = 0
  private var trackList: [String] = [String]()
  
  func setupAuth() {
    auth?.clientID = EQSpotifyClientInfo.clientID.rawValue
    auth?.redirectURL = URL(string: EQSpotifyClientInfo.redirectURL.rawValue)!
    auth?.requestedScopes = [SPTAuthStreamingScope, SPTAuthPlaylistReadPrivateScope, SPTAuthUserReadEmailScope]
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
    player!.playbackDelegate = self
    player!.delegate = self
    do {
      try player?.start(withClientId: auth?.clientID, audioController: coreAudioController, allowCaching: false)
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
  func playTrack(){
    player?.playSpotifyURI(trackList[currentPlayIndex], startingWith: 0, startingWithPosition: 0, callback: { (error) in
      
    })
  }
  func skip(){
    currentPlayIndex+=1
    if currentPlayIndex >= trackList.count {
      currentPlayIndex = trackList.count-1
      return
    }
    playTrack()
  }
  
  func previous(){
    currentPlayIndex-=1
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
    for index in 0..<bandValues.count {
      coreAudioController.setGain(value: bandValues[index], forBandAt: UInt32(index))
    }
  }
  
  
}

extension EQSpotifyManager {
  
  func audioStreamingDidLogin(_: SPTAudioStreamingController!) {
    AppDelegate.shard?.switchToMainStoryBoard()
  }
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
    print("start")
    delegate?.didChangeTrack(track: (player?.metadata.currentTrack)!)
  }
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
    skip()
    print("stop")
  }
 
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
    delegate?.didChangePlaybackStatus(isPlaying: isPlaying)
  }
  func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
    delegate?.didPositionChange(position: position)
  }
}
