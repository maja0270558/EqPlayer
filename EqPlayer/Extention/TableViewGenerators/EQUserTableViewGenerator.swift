//
//  EQUserTableViewGenerator.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
enum EQUserPageTableViewSectionGenerator {
    case userInfoCell
    case toolBar
}
extension EQUserTableViewController {
     func createUserInfoHead() -> EQSectionProvider {
        let section = EQSectionProvider()
        userTableView.registeCell(cellIdentifier: EQUserInfoTableViewCell.typeName)
        section.cellIdentifier = EQUserInfoTableViewCell.typeName
        section.cellDatas = ["Django Free"]
        section.cellHeight = UITableViewAutomaticDimension
        section.cellOperator = { data, view in
        }
        return section
    }
     func createCustomToolBarSectionWithCell() -> EQSectionProvider{
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
    func generateSectionAndCell(providerTypes: [EQUserPageTableViewSectionGenerator]) -> [EQSectionProvider]{
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
