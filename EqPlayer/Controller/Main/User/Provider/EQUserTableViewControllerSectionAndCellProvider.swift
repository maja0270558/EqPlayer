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
        section.cellOperator = { _, cell, _ in
            guard let infoCell = cell as? EQUserInfoTableViewCell else {
                return
            }
            infoCell.userName.text = EQUserProvider.getUserName()
            infoCell.userImage.sd_setImage(with: EQUserProvider.getUserPhotoURL(), completed: nil)
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
                toolBar.backgroundColor = UIColor.clear
                toolBar.delegate = self
                toolBar.datasource = self
            }
        }
        section.cellDatas = eqData
        section.cellHeight = UITableViewAutomaticDimension
        userTableView.registeCell(cellIdentifier: EQSaveProjectCell.typeName)
        section.cellIdentifier = EQSaveProjectCell.typeName
        section.cellOperator = {
            data, cell, indexPath in
            guard let saveCell = cell as? EQSaveProjectCell, let eqModel = data as? EQProjectModel else {
                return
            }
            saveCell.delegate = self
            saveCell.cellIndexPath = indexPath
            let buttonImage = eqModel.status == EQProjectModel.EQProjectStatus.saved ? UIImage(named: "play") : UIImage(named: "wrench")
            saveCell.projectTitleLabel.text = eqModel.name
            saveCell.cellIndicator.startAnimating()
            saveCell.trackCountLabel.text = String(eqModel.tracks.count)
            saveCell.playbutton.setBackgroundImage(buttonImage, for: .normal)
            let imageURLs = eqModel.tracks.map {
                $0.coverURL!
            }
            saveCell.cellEQChartView.alpha = 0
            saveCell.cellEQChartView.isUserInteractionEnabled = false
            saveCell.setDiscsImage(imageURLs: Array(imageURLs)) {
                let color = self.getProperColor(color: (saveCell.discImageLarge.image?.getPixelColor(saveCell.discImageLarge.center))!)
                saveCell.cellEQChartView.setChart(15, color: color, style: .cell)
                saveCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
                saveCell.cellIndicator.stopAnimating()
                UIView.animate(withDuration: 0.3, animations: {
                    saveCell.cellEQChartView.alpha = 1
                })
            }
        }
        return section
    }

    func getProperColor(color: UIColor) -> UIColor {
        if color.isLightColor() {
            return color
        }
        return color.lighter(by: 60)!
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
