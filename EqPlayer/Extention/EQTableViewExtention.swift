//
//  EQTableViewExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension UITableView {
    func registeCell(cellIdentifier: String) {
        register(
            UINib(nibName: cellIdentifier, bundle: nil),
            forCellReuseIdentifier: cellIdentifier
        )
    }
}

extension UITableViewCell {
    var otherTypeName: String {
        let thisType = type(of: self)
        return String(describing: thisType)
    }

    static var typeName: String {
        return String(describing: self)
    }
}

protocol TableViewDelegateAndDataSource: UITableViewDelegate, UITableViewDataSource {
    
}
