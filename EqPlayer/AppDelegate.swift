//
//  AppDelegate.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import Firebase
import IQKeyboardManager
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shard = UIApplication.shared.delegate as? AppDelegate
    let spotifyManager = EQSpotifyManager.shard
    var window: UIWindow?

    func applicationDidEnterBackground(_ application: UIApplication) {
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectAccidentallyClose)
    }
    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared().isEnabled = true
        IQKeyboardManager.shared().shouldResignOnTouchOutside = true

        FirebaseApp.configure()
        spotifyManager.setupAuth()
        if let session = spotifyManager.auth?.session {
            if session.isValid() {
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
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
                self.spotifyManager.authViewController?.dismiss(animated: true, completion: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "loginSuccessfull"), object: nil)
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
}
