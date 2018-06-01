//
//  EQProjectModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import RealmSwift
@objc enum EQProjectStatus: Int {
  case new
  case saved
  case temp
  case post
  func getValue() -> String {
    return String(rawValue)
  }
}
class EQProjectModel: Object {
  var dict: [String : Any] {
    return [
      "uuid": uuid,
      "name": name,
      "status": status.getValue(),
      "tracks": Array(tracks).map {
        return $0.dict
      },
      "eqSetting": Array(eqSetting),
      "detailDescription": detailDescription
    ]
  }
    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var detailDescription: String = ""
    @objc dynamic var status = EQProjectStatus.new
    let tracks = List<EQTrack>()
    let eqSetting = List<Double>()
}

class EQTrack: Object, Codable {
  
  var dict: [String : Any] {
    return [
      "duration": duration,
      "name": name,
      "uri": uri,
      "artist": artist,
      "previewURL": previewURL,
      "coverURL": coverURL
    ]
  }
  
    @objc dynamic var duration: TimeInterval = 0
    @objc dynamic var name: String = ""
    @objc dynamic var uri: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var previewURL: String?
    @objc dynamic var coverURL: String?
}
