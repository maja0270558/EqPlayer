//
//  AppDelegate.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import Crashlytics
import Fabric
import Firebase
import IQKeyboardManager
import MediaPlayer
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shard = UIApplication.shared.delegate as? AppDelegate
    let spotifyManager = EQSpotifyManager.shard
    var window: UIWindow?

    func applicationWillTerminate(_: UIApplication) {
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectAccidentallyClose)
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true
        FirebaseApp.configure()
        spotifyManager.setupAuth()
        window?.insertSubview(MPVolumeView(), at: 0)

        if let session = spotifyManager.auth?.session {
            if session.isValid() {
                EQUserManager.shard.saveUserInfo {
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                }
                return true
            }
        }
        switchToLoginStoryBoard()
        return true
    }

    func application(_: UIApplication, open url: URL, options _: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if (spotifyManager.auth?.canHandle(url))! {
            spotifyManager.auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { error, _ in
                if error != nil {
                    print("error!")
                }
                self.spotifyManager.authViewController?.dismiss(animated: true) {
                    self.switchToLoadingStoryBoard()
                    EQUserManager.shard.saveUserInfo {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
                    }
                }

            })
            return true
        }
        return false
    }

    func switchToLoginStoryBoard() {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.switchToLoginStoryBoard()
            }
            return
        }
        window?.rootViewController = UIStoryboard.loginStoryBoard().instantiateInitialViewController()
    }

    func switchToMainStoryBoard() {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.switchToMainStoryBoard()
            }
            return
        }
        let viewController = UIStoryboard.mainStoryBoard().instantiateInitialViewController()
        window?.rootViewController = viewController
    }

    func switchToLoadingStoryBoard() {
        if !Thread.current.isMainThread {
            DispatchQueue.main.async { [weak self] in
                self?.switchToMainStoryBoard()
            }
            return
        }
        let viewController = UIStoryboard.loadingBoard().instantiateInitialViewController()
        window?.rootViewController = viewController
    }
}
