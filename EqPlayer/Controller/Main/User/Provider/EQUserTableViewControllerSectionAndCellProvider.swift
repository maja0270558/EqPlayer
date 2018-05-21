//
//  EQUserTableViewControllerSectionAndCellProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
enum EQUserTableViewControllerSectionAndCellProvider: Int, EnumCollection {
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
    section.cellOperator = { _, _ in
    }
    return section
  }
  
  func createCustomToolBarSectionWithCell() -> EQSectionProvider {
    let section = EQSectionProvider()
    section.headerHeight = UITableViewAutomaticDimension
    section.headerView = EQCustomToolBarView()
    section.headerData = barData
    section.headerOperator = {
      _, view in
      if let toolBar = view as? EQCustomToolBarView {
        toolBar.delegate = self
        toolBar.datasource = self
      }
    }
    section.cellDatas = eqDatas
    section.cellHeight = UITableViewAutomaticDimension
    userTableView.registeCell(cellIdentifier: EQSaveProjectCell.typeName)
    section.cellIdentifier = EQSaveProjectCell.typeName
    section.cellOperator = {
      data, cell in
      guard let saveCell = cell as? EQSaveProjectCell,let eqModel = data as? EQProjectModel else {
        return
      }
      saveCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
      saveCell.projectTitleLabel.text = eqModel.name
      saveCell.playlistCover.sd_setImage(with: URL(string: (eqModel.tracks.first?.coverURL!)!), completed: nil)
    }
    return section
  }
  
  func generateSectionAndCell() {
    var providers = [EQSectionProvider]()
    for sectionType in Array(EQUserTableViewControllerSectionAndCellProvider.cases()) {
      switch sectionType {
      case .toolBar:
        providers.append(createCustomToolBarSectionWithCell())
      case .userInfoCell:
        providers.append(createUserInfoHead())
      }
    }
    sectionProviders = providers
  }
}
