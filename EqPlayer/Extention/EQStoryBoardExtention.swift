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
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }
}
