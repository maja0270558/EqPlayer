//
//  EQFirebaseManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/31.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import FirebaseAuth

class EQFirebaseManager {
  
  static func createUserIfNotExist(withEmail: String ,password: String, succesfullyLoginCallBack: @escaping () -> Void = { return }) {
      Auth.auth().createUser(withEmail: withEmail, password: password) {
      (user, error) in
        if let errCode = AuthErrorCode(rawValue: error!._code) {
          switch errCode {
          case .emailAlreadyInUse:
            Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
              if error != nil {
                print(error?.localizedDescription)
              }
              print("succesfully login")
              succesfullyLoginCallBack()
            })
          default:
            print("Create User Error: \(error)")
          }
        }
        else {
          print("create succesfully")
          Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error != nil {
              print(error?.localizedDescription)
            }
            print("succesfully login")
            succesfullyLoginCallBack()
          })
      }
    }
  }
}
