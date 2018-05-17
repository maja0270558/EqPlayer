//
//  EQProjectModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import RealmSwift

class EQProjectModel: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var isSave: Bool = false
    let tracks = List<EQTrack>()
    let eqSetting = List<Float>()
}
class EQTrack: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var uri: String = ""
    @objc dynamic var artist:String = ""
    @objc dynamic var previewURL: String?
    @objc dynamic var coverURL: String?
}
