//
//  EQUserModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

struct EQUserModel: Codable {
    var name: String = ""
    var email: String = ""
    var photoURL: URL?
}
