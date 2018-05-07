//
//  AppDelegate.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Firebase
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    static let shard = UIApplication.shared.delegate as? AppDelegate
    let spotifyManager = EQSpotifyManager()
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        if (spotifyManager.auth?.canHandle(url))! {
            spotifyManager.auth?.handleAuthCallback(withTriggeredAuthURL: url, callback: { (error, _) in
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
        window?.rootViewController = UIStoryboard.mainStoryBoard().instantiateInitialViewController()
    }

}
