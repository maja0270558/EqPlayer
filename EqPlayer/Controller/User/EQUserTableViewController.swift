//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQUserTableViewController: EQTableViewController, ScrollableController {
    var icon: UIImage?

    @IBOutlet var userTableView: UITableView!

    override func viewDidLoad() {
        setupTableView()
    }

    func setupTableView() {
        userTableView.delegate = self
        userTableView.dataSource = self
        let sessionInfo = EQSectionProvider()
        sessionInfo.headerData = 0
        sessionInfo.headerHeight = UITableViewAutomaticDimension
        sessionInfo.headerView = UserInfoHeaderView()
        sessionInfo.cellDatas = [0, 2, 0]
        sessionInfo.cellHeight = UITableViewAutomaticDimension
        sessionInfo.cellOperator = { data, cell in
            guard let nay = data as? Int else {
                fatalError("")
            }
            cell.textLabel?.text = "cell \(nay)"
        }
        setupSession(sectionData: [sessionInfo])
    }

    func createSections() {
    }

    func setupSession(sectionData: [EQTableViewSession]) {
        sectionProviders = sectionData
    }
}
