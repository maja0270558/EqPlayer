//
//  +EQFoundationExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/5.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
