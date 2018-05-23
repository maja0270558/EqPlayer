//
//  EQUserTableViewControllerSectionAndCellProvider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import UIImageColors
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
    section.cellDatas = eqData
    section.cellHeight = UITableViewAutomaticDimension
    userTableView.registeCell(cellIdentifier: EQSaveProjectCell.typeName)
    section.cellIdentifier = EQSaveProjectCell.typeName
    section.cellOperator = {
      data, cell in
      guard let saveCell = cell as? EQSaveProjectCell,let eqModel = data as? EQProjectModel else {
        return
      }
      let buttonImage = eqModel.status == EQProjectModel.EQProjectStatus.saved ? UIImage(named: "play") : UIImage(named: "wrench")
      saveCell.projectTitleLabel.text = eqModel.name
      saveCell.cellIndicator.startAnimating()
      saveCell.trackCountLabel.text = String(eqModel.tracks.count)
      saveCell.playbutton.setBackgroundImage(buttonImage, for: .normal)
      let imageURLs = eqModel.tracks.map {
        $0.coverURL!
      }
      saveCell.setDiscsImage(imageURLs: Array(imageURLs)) {
        saveCell.discImageLarge.image?.getColors(quality: UIImageColorsQuality.low, { (color) in
          let colorArray = [color.background, color.detail]
          var lightColor = self.getLightest(colors: colorArray)
          saveCell.cellEQChartView.setChart(15, color: lightColor, style: .cell)
          saveCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
          saveCell.cellIndicator.stopAnimating()
          UIView.animate(withDuration: 0.3, animations: {
            saveCell.cellEQChartView.alpha = 1
          })
        })
      }
      saveCell.cellEQChartView.alpha = 0

    }
    return section
  }
  
  func getLightest(colors: [UIColor?]) -> UIColor
  {
    var brightnessArray = [CGFloat]()
    colors.forEach {
      guard let components = $0?.cgColor.components else {
        brightnessArray.append(0)
        return
      }
      let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
      brightnessArray.append(brightness)
    }
    var brightestIndex = brightnessArray.index(of: brightnessArray.max()!)
    return colors[brightestIndex!]!
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
