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
        if self.visibleCells != nil, self.visibleCells.count != 0 {
            guard let topCell = self.visibleCells.first else {
                return
            }
            var modifier:CGFloat = 2.5
            for cell in self.visibleCells {
                cell.contentView.alpha = 1.0
            }
            let cellHeight = topCell.frame.size.height
            let tableViewTopPosition = self.frame.origin.y
            let tableViewBottomPosition = self.frame.origin.y + self.frame.size.height
            let topCellPositionInTableView = self.rectForRow(at: self.indexPath(for: topCell)!)
            let topCellPosition = self.convert(topCellPositionInTableView, to: self.superview!)
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
