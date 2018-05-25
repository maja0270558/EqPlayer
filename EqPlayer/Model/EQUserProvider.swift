//
//  EQUserProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/25.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQUserProvider {
    static func getUserName() -> String {
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        return name
    }

    static func getUserPhotoURL() -> URL? {
        let url = UserDefaults.standard.string(forKey: "userPhotoURL") ?? ""
        return URL(string: url)
    }
}
