//
//  +EQUITableViewCellExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/25.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

extension UITableViewCell {
    func setSelectedColor(color: UIColor = UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 0.3)) {
        let myCustomSelectionColorView = UIView()
        myCustomSelectionColorView.backgroundColor = color
        selectedBackgroundView = myCustomSelectionColorView
    }

    var otherTypeName: String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }

    static var typeName: String {
        return String(describing: self)
    }
}
