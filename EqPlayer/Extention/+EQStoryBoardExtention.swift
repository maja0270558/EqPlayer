//
//  EQStoryBoardExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension UIStoryboard {
    static func loginStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }

    static func mainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    static func eqProjectStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "EQProject", bundle: nil)
    }

    static func loadingBoard() -> UIStoryboard {
        return UIStoryboard(name: "Loading", bundle: nil)
    }
}
