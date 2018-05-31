//
//  EQUserManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import PopupDialog

enum UserStatus {
  case spotify
  case guest
  case expire
}

class EQUserManager {
  private init() {}
  static let shard = EQUserManager()
 
  var userStatus: UserStatus {
    if let session = EQSpotifyManager.shard.auth?.session {
      if !session.isValid() {
        return UserStatus.guest
      }else {
        return UserStatus.spotify
      }
    }
    return UserStatus.guest
  }
  
  func saveUserInfo(_ callback: @escaping ()->Void) {
    SPTUser.requestCurrentUser(withAccessToken: (SPTAuth.defaultInstance().session.accessToken)!) { _, data in
      guard let currentUser = data as? SPTUser else {
        print("Couldn't cast as SPTUser")
        return
      }
      switch currentUser.product {
      case .premium:
        break
      case .free, .unlimited , .unknown:
        EQSpotifyManager.shard.auth?.session = nil
        EQAlertViewControllerSetting.setDarkMode()
        let title = "提示"
        let message = "您登入的帳號並不是Spotify premium，也許你會想升級體驗，按下確定將跳轉回登入頁面。"
        let popup = PopupDialog(title: title, message: message, image: nil)
        popup.transitionStyle = .zoomIn
        popup.buttonAlignment = .horizontal
        
        let close = DefaultButton(title: "確定", height: 60) {
          AppDelegate.shard?.switchToLoginStoryBoard()
        }
        popup.addButtons([close])
        AppDelegate.shard?.window?.rootViewController?.present(popup, animated: true, completion: nil)
        return
      }
      
      
      let userId = currentUser.displayName ?? currentUser.canonicalUserName
      if let userImage = currentUser.largestImage {
        UserDefaults.standard.set(userImage.imageURL.absoluteString, forKey: "userPhotoURL")
      }
      let email = currentUser.emailAddress
      EQFirebaseManager.createUserIfNotExist(withEmail: email!, password: currentUser.canonicalUserName)
      UserDefaults.standard.set(userId, forKey: "userName")
      UserDefaults.standard.set(email, forKey: "email")
      callback()
    }
  }
  
  func getUser() -> EQUserModel {
    let name = getUserName()
    let email = getUserEmail()
    let photo = getUserPhotoURL()
    let userModel = EQUserModel(name: name, email: email, photoURL: photo)
    return userModel
  }
  
  func getUserName() -> String {
    let name = UserDefaults.standard.string(forKey: "userName") ?? "訪客"
    return name
  }
  func getUserEmail() -> String {
    let name = UserDefaults.standard.string(forKey: "email") ?? "none"
    return name
  }
  func getUserPhotoURL() -> URL? {
    let url = UserDefaults.standard.string(forKey: "userPhotoURL") ?? ""
    return URL(string: url)
  }
}
