//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQUserTableViewController: EQTableViewController {
    var icon: UIImage?
    var sections: [EQUserPageTableViewSectionGenerator] = [.userInfoCell, .toolBar]
    var barData = ["Posted", "Saved", "Liked"]
    @IBOutlet var userTableView: UITableView!

    override func viewDidLoad() {
        setupTableView()
        setupSession(sectionData: generateSectionAndCell(providerTypes: sections))
    }

    func setupTableView() {
        userTableView.contentInsetAdjustmentBehavior = .never
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.separatorStyle = .none
    }

    func setupSession(sectionData: [EQTableViewSession]) {
        sectionProviders = sectionData
    }
}

extension EQUserTableViewController: EQCustomToolBarDataSource, EQCustomToolBarDelegate {
    func eqToolBarNumberOfItem() -> Int {
        return barData.count
    }

    func eqToolBar(titleOfItemAt: Int) -> String {
        return barData[titleOfItemAt]
    }

    func eqToolBar(didSelectAt: Int) {
        print("Selet at \(didSelectAt)")
    }
}
