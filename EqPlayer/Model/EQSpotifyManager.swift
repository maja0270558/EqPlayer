//
//  EQSpotifyManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import SafariServices
class EQSpotifyManager: NSObject, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, SPTCoreAudioControllerDelegate {
    let userDefaults = UserDefaults.standard
    var player = SPTAudioStreamingController.sharedInstance()
    var auth = SPTAuth.defaultInstance()
    var authViewController: SFSafariViewController?
    var loginURL: URL?

    var session: SPTSession!
    var coreAudioController = EQSpotifyCoreAudioController()

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

    func audioStreamingDidLogin(_: SPTAudioStreamingController!) {
        AppDelegate.shard?.switchToMainStoryBoard()
    }
}
