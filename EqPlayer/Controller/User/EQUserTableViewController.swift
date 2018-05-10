//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
enum EQUserPageTableViewSectionGenerator {
    case userInfoCell
    case toolBar
}
class EQUserTableViewController: EQTableViewController, ScrollableController {
    var icon: UIImage?
    var sections:[EQUserPageTableViewSectionGenerator] = [.userInfoCell, .toolBar]
    var barData = ["Posted", "Saved", "Liked"]
    @IBOutlet var userTableView: UITableView!
    
    override func viewDidLoad() {
        setupTableView()
    }
    
    func setupTableView() {
        userTableView.contentInsetAdjustmentBehavior = .never
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.separatorStyle = .none
        setupSession(sectionData: generateSectionAndCell(providerTypes: sections))
    }
    
    func createSections() {
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

extension EQUserTableViewController {
    private func createUserInfoHead() -> EQSectionProvider {
        let section = EQSectionProvider()
        userTableView.registeCell(cellIdentifier: EQUserInfoTableViewCell.typeName)
        section.cellIdentifier = EQUserInfoTableViewCell.typeName
        section.cellDatas = ["Django Free"]
        section.cellHeight = UITableViewAutomaticDimension
        section.cellOperator = { data, view in
        }
        return section
    }
    private func createCustomToolBarSectionWithCell() -> EQSectionProvider{
        let section = EQSectionProvider()
        section.headerHeight = UITableViewAutomaticDimension
        section.headerView = EQCustomToolBarView()
        section.headerData = barData
        section.headerOperator = {
            (data,view) in
            if let toolBar = view as? EQCustomToolBarView {
                toolBar.delegate = self
                toolBar.datasource = self
            }
        }
        section.cellDatas = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        section.cellHeight = 150
        section.cellOperator = {
            (data, cell) in
            cell.textLabel?.text = "0"
        }
        
        return section
    }
    
    //Must call after get data
    private func generateSectionAndCell(providerTypes: [EQUserPageTableViewSectionGenerator]) -> [EQSectionProvider]{
        var providers = [EQSectionProvider]()
        for sectionType in providerTypes {
            switch sectionType {
            case .toolBar:
              providers.append(createCustomToolBarSectionWithCell())
            case .userInfoCell:
                providers.append(createUserInfoHead())
            }
        }
        return providers
    }
}
