//
//  EQProjectModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import RealmSwift

class EQProjectModel: Object {
    @objc enum EQProjectStatus: Int {
        case new
        case saved
        case temp
      func getValue() -> String {
        return String(self.rawValue)
      }
    }

    @objc dynamic var uuid = UUID().uuidString
    @objc dynamic var name: String = ""
    @objc dynamic var status = EQProjectStatus.new
    let tracks = List<EQTrack>()
    let eqSetting = List<Double>()
}

class EQTrack: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var uri: String = ""
    @objc dynamic var artist: String = ""
    @objc dynamic var previewURL: String?
    @objc dynamic var coverURL: String?
}
