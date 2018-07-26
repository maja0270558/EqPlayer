//
//  EQSpotifyClientInfo.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

enum EQSpotifyClientInfo: String {
    case clientID = "8a7aff6cb6d141b3bdba8695d133c7bd"

    case redirectURL = "eqplayer://returnafterlogin"

    case sessionKey = "SpotifySession"

    func string() -> String {
        return rawValue
    }
}
