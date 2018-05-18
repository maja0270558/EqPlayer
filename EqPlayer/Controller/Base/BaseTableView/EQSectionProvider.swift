//
//  EQSectionProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQSectionProvider: EQTableViewSession {
    var headerIdentifier: String?
    var headerView: UIView?
    var headerHeight: CGFloat = 0
    var headerOperator: (Any, UIView) -> Void = { _, _ in return }
    var headerData: Any?
    var cellIdentifier: String?
    var cell: UITableViewCell?
    var cellHeight: CGFloat = 0
    var cellOperator: (Any, UITableViewCell) -> Void = { _, _ in return }
    var cellDatas: [Any] = []
}
