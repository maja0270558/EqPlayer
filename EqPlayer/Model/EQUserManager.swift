//
//  EQUserManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
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
      guard let user = data as? SPTUser else {
        print("Couldn't cast as SPTUser")
        return
      }
      let userId = user.displayName
      let userPhotoURL = user.largestImage.imageURL.absoluteString
      let email = user.emailAddress
      UserDefaults.standard.set(userId, forKey: "userName")
      UserDefaults.standard.set(email, forKey: "email")
      UserDefaults.standard.set(userPhotoURL, forKey: "userPhotoURL")

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
