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
        userTableView.contentInsetAdjustmentBehavior = .never
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.separatorStyle = .none
        let sessionInfo = EQSectionProvider()

        userTableView.register(UINib(nibName: EQUserInfoTableViewCell.typeName, bundle: nil), forCellReuseIdentifier: EQUserInfoTableViewCell.typeName)
        sessionInfo.cellIdentifier = EQUserInfoTableViewCell.typeName

        sessionInfo.cellDatas = ["Django Free"]
        sessionInfo.cellHeight = UITableViewAutomaticDimension
        sessionInfo.cellOperator = { data, _ in
            guard let nay = data as? String else {
                fatalError("")
            }
//            cell.textLabel?.text = "\(nay)"
        }
        
        let sessionInfo2 = EQSectionProvider()
        sessionInfo2.headerData = 0
        sessionInfo2.headerHeight = UITableViewAutomaticDimension
        sessionInfo2.headerView = UserInfoHeaderView()
        sessionInfo2.cellDatas = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        sessionInfo2.cellHeight = 150
        sessionInfo2.cellOperator = {
            (data, cell) in
            cell.textLabel?.text = "0"
        }
      
        setupSession(sectionData: [sessionInfo, sessionInfo2])
    }

    func createSections() {
    }

    func setupSession(sectionData: [EQTableViewSession]) {
        sectionProviders = sectionData
    }
}
