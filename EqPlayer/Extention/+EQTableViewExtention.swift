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

    func reloadDataUpdateFade() {
        reloadData()
        fadeTopCell()
    }

    func reloadRowsInSection(section: Int, oldCount: Int, newCount: Int) {
        let maxCount = max(oldCount, newCount)
        let minCount = min(oldCount, newCount)

        var changed = [IndexPath]()

        for index in minCount ..< maxCount {
            let indexPath = IndexPath(row: index, section: section)
            changed.append(indexPath)
        }

        var reload = [IndexPath]()
        for index in 0 ..< minCount {
            let indexPath = IndexPath(row: index, section: section)
            reload.append(indexPath)
        }
        UIView.performWithoutAnimation {
            beginUpdates()
            if newCount > oldCount {
                insertRows(at: changed, with: .fade)
            } else if oldCount > newCount {
                deleteRows(at: changed, with: .fade)
            }

            reloadRows(at: reload, with: .fade)

            endUpdates()
        }
        fadeTopCell()
    }
}

protocol TableViewDelegateAndDataSource: UITableViewDelegate, UITableViewDataSource {
}
