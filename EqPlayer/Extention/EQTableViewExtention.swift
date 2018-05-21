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

    func fadeTopCell() {
        if visibleCells.count != 0 {
          guard let topCell = self.visibleCells.first, let indexPath = indexPath(for: topCell) else {
                return
            }
            let modifier: CGFloat = 3
            for cell in visibleCells {
                cell.contentView.alpha = 1.0
            }
            let cellHeight = topCell.frame.size.height
            let tableViewTopPosition = frame.origin.y
            let topCellPositionInTableView = rectForRow(at: indexPath)
            let topCellPosition = convert(topCellPositionInTableView, to: superview!)
            let topCellOpacity = (1.0 - ((tableViewTopPosition - topCellPosition.origin.y) / cellHeight) * modifier)
            topCell.contentView.alpha = topCellOpacity
        }
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
