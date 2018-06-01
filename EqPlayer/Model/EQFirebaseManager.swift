//
//  EQFirebaseManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/31.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import SDWebImage

class EQFirebaseManager {
  
  static func createUserIfNotExist(withEmail: String ,password: String, succesfullyLoginCallBack: @escaping () -> Void = { return }) {
    Auth.auth().createUser(withEmail: withEmail, password: password) {
      (user, error) in
      
      if let loginError = error, let errCode = AuthErrorCode(rawValue: loginError._code) {
        switch errCode {
        case .emailAlreadyInUse:
          signin(withEmail: withEmail, password: password, succesfullyLoginCallBack: succesfullyLoginCallBack)
        default:
          print("Create User Error: \(error)")
        }
      }
      else {
        print("create succesfully")
        signin(withEmail: withEmail, password: password, succesfullyLoginCallBack: succesfullyLoginCallBack)
      }
    }
  }

  static func signin(withEmail: String, password: String, succesfullyLoginCallBack: @escaping () -> Void = { return }){
    Auth.auth().signIn(withEmail: withEmail, password: password, completion: { (user, error) in
      if error != nil {
        print(error?.localizedDescription)
      }
      guard let currentUser = user else {
        return
      }
      EQUserManager.shard.userUID = currentUser.uid
      EQFirebaseManager.updateUserDatabase(userUID: currentUser.uid) {
        succesfullyLoginCallBack()
      }
    })
  }
  
  static func getPost(withPath: String, completion: @escaping ([EQPostCellModel]) -> Void) {
    let ref = Database.database().reference().child(withPath)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      let models = convertSnapshotToModel(snapshot: snapshot)
      DispatchQueue.main.async {
        completion(models)
      }
    }
  }
  
  static func getUser(withUID: String ,failedHandler: @escaping () -> Void, completion: @escaping (EQUserModel) -> Void) {
    let ref = Database.database().reference().child("user").child(withUID)
    ref.observeSingleEvent(of: .value) { (snapshot) in
      guard let dictionary = snapshot.value as? [String: Any] else {
        failedHandler()
        return
      }
      guard let name = dictionary["name"] as? String ,
        let email = dictionary["email"] as? String ,
        let image = dictionary["image"] as? String ,
        let like = dictionary["like"] as? [String] else {
          failedHandler()
          return
        }
      let userModel = EQUserModel(name: name, email: email, photoURL: URL(string: image))
      completion(userModel)
    }
  }
  
  static func updateUserDatabase(userUID: String, completion: @escaping () -> Void = { return }){
    let ref = Database.database().reference().child("user")
    let storageRef = Storage.storage().reference().child("userPhoto")
    let user =  EQUserManager.shard.getUser()
    let imageURLString = (user.photoURL == nil) ? "": (user.photoURL?.absoluteString)!
   
    getUser(withUID: userUID,
    failedHandler: {
      ref.child(userUID).setValue([
        "name": user.name,
        "email": user.email,
        "image": imageURLString,
        "like": [
          "projectId"
        ]
        ])
      UserDefaults.standard.set(imageURLString, forKey: "userPhotoURL")
      completion()
    },
    completion: { userModel in
      UserDefaults.standard.set(userModel.name, forKey: "userName")
      UserDefaults.standard.set(userModel.email, forKey: "email")
      UserDefaults.standard.set(userModel.photoURL?.absoluteString, forKey: "userPhotoURL")
      completion()
    })
  }
  
  static func uploadImage(userUID: String,image: UIImage, completion: @escaping (String) -> Void = {string in return}){
    let storageRef = Storage.storage().reference().child("userPhoto").child(userUID)
    let ref = Database.database().reference().child("user")
    
    if let imageData = UIImageJPEGRepresentation(image, 0.2) {
      let metadata = StorageMetadata()
      metadata.contentType = "image/png"
      let task = storageRef.putData(imageData, metadata: metadata)
      task.observe(.success) { (snapshot) in
        let downloadURL = snapshot.metadata?.downloadURL()?.absoluteString
        ref.child("\(userUID)").updateChildValues(["image": downloadURL!])
        UserDefaults.standard.set(downloadURL!, forKey: "userPhotoURL")
        completion(downloadURL!)
      }
    }
  }
  
  
  static func convertSnapshotToModel(snapshot: DataSnapshot) -> [EQPostCellModel] {
    var cellModels = [EQPostCellModel]()
    
    guard let postArray = snapshot.value as? [String: Any] else {
      return cellModels
    }
    
    for post in postArray {
      var eqPostCellModel = EQPostCellModel()
      var eqProjectModel = EQProjectModel()
      var eqTrackList = [EQTrack]()
      guard let dictionary = post.value as? [String: Any] else {
        return cellModels
      }
      guard let postTime = dictionary["postTime"] as? Double,
        let postUserName =  dictionary["postUserName"] as? String,
        let postUserUID = dictionary["postUserUID"] as? String
        else {
          return cellModels
      }
      let postUserPhotoURL = dictionary["postUserPhotoURL"] as? String ?? "none"
      guard let projectModelDictionary =  dictionary["projectModel"] as? [String: Any] else {
        return cellModels
      }
      guard
        let eqSetting = projectModelDictionary["eqSetting"] as? [Double],
        let eqProjectName =  projectModelDictionary["name"] as? String,
        let eqProjectStatus = projectModelDictionary["status"] as? String,
        let eqProjectDescription = projectModelDictionary["detailDescription"] as? String,
        let eqProjectUUID = projectModelDictionary["uuid"] as? String
        else {
          return cellModels
      }
      guard let eqProjectTracks =  projectModelDictionary["tracks"] as? [[String:Any]] else {
        return cellModels
      }
      for track in eqProjectTracks {
        if let jsonData = try? JSONSerialization.data(withJSONObject: track, options: []) {
          if let trackData = try? JSONDecoder().decode(EQTrack.self, from: jsonData) {
            eqTrackList.append(trackData)
          }
        }
      }
      eqProjectModel.name = eqProjectName
      eqProjectModel.uuid = eqProjectUUID
      eqProjectModel.status = EQProjectStatus(rawValue: Int(eqProjectStatus)!)!
      eqProjectModel.detailDescription = eqProjectDescription
      
      eqProjectModel.tracks.append(objectsIn: eqTrackList)
      eqProjectModel.eqSetting.append(objectsIn: eqSetting)
      
      eqPostCellModel.postTime = postTime
      eqPostCellModel.postUserName = postUserName
      eqPostCellModel.postUserUID = postUserUID
      eqPostCellModel.postUserPhotoURL = postUserPhotoURL
      eqPostCellModel.projectModel = eqProjectModel
      
      cellModels.append(eqPostCellModel)
    }
    return cellModels
    
  }
  
  static func postEQProject(projectModel: EQProjectModel){
    let ref = Database.database().reference().child("post")
    let userRef = Database.database().reference().child("userPosts")
    let user =  EQUserManager.shard.getUser()
    let photoURLString = (user.photoURL == nil) ? "": (user.photoURL?.absoluteString)!
    let modelDic: [String: Any] = [
      "postUserUID": EQUserManager.shard.userUID,
      "postUserName": user.name,
      "postUserPhotoURL": photoURLString,
      "postTime": ServerValue.timestamp(),
      "projectModel": projectModel.dict
    ]
    userRef.child(EQUserManager.shard.userUID).child(projectModel.uuid).setValue(modelDic)
    ref.child(projectModel.uuid).setValue(modelDic)
  }
  
}
