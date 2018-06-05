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

enum UserToolBarProvider: Int {
    case saved = 1
    case temp = 2
    case posted = 3

    func getName() -> String {
        switch self {
        case .saved:
            return "已儲存"
        case .temp:
            return "施工中"
        case .posted:
            return "已發布"
        default:
            break
        }
    }
}

extension EQUserTableViewController {
    @objc func changeProfilePhoto() {
        EQCameraHandler.shared.showActionSheet(vc: self)
        EQCameraHandler.shared.imagePickedBlock = { image in
            EQFirebaseManager.uploadImage(userUID: EQUserManager.shard.userUID, image: image) {
                _ in
                self.sessionOf(EQUserTableViewControllerSectionAndCellProvider.userInfoCell.rawValue).cellDatas = [EQUserManager.shard.getUser()]
                DispatchQueue.main.async {
                    self.userTableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                }
            }
        }
    }

    func createUserInfoHead() -> EQSectionProvider {
        let section = EQSectionProvider()
        userTableView.registeCell(cellIdentifier: EQUserInfoTableViewCell.typeName)
        section.cellIdentifier = EQUserInfoTableViewCell.typeName
        section.cellDatas = [EQUserManager.shard.getUser()]
        section.cellHeight = UITableViewAutomaticDimension
        section.cellOperator = { data, cell, _ in
            guard let infoCell = cell as? EQUserInfoTableViewCell, let userArray = data as? EQUserModel else {
                return
            }
            infoCell.cameraButton.addTarget(self, action: #selector(self.changeProfilePhoto), for: .touchUpInside)
            infoCell.userName.text = userArray.name
            infoCell.userImage.sd_setImage(with: userArray.photoURL, placeholderImage: #imageLiteral(resourceName: "dark-1920956_1280"), options: [], completed: nil)
        }
        return section
    }

    func createCustomToolBarSectionWithCell() -> EQSectionProvider {
        let section = EQSectionProvider()
        var toolBarTitleData = [UserToolBarProvider.saved.getName(), UserToolBarProvider.temp.getName(), UserToolBarProvider.posted.getName()]
        section.headerHeight = UITableViewAutomaticDimension
        section.headerView = EQCustomToolBarView()
        section.headerData = toolBarTitleData
        section.headerOperator = {
            _, view in
            if let toolBar = view as? EQCustomToolBarView {
                toolBar.backgroundColor = UIColor.clear
                toolBar.delegate = self
                toolBar.datasource = self
            }
        }

        if EQUserManager.shard.userStatus == .guest {
            section.headerData = ["已儲存的專案"]
            section.cellDatas = [ { return }]
            section.cellHeight = UITableViewAutomaticDimension
            userTableView.registeCell(cellIdentifier: EQGusetTableViewCell.typeName)
            section.cellIdentifier = EQGusetTableViewCell.typeName
            section.cellOperator = {
                _, cell, _ in
                guard let hintCell = cell as? EQGusetTableViewCell else {
                    return
                }
                hintCell.backToLogin = {
                    AppDelegate.shard?.switchToLoginStoryBoard()
                }
                hintCell.selectionStyle = .none
            }
            return section
        }
        if let indexType = UserToolBarProvider(rawValue: currentToolItemIndex) {
            section.cellDatas = userPageData[indexType]!
        }
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
            let buttonImage = eqModel.status == EQProjectStatus.temp ? UIImage(named: "wrench") : UIImage(named: "play")
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

extension EQUserTableViewController: EQCustomToolBarDataSource, EQCustomToolBarDelegate {
    func eqToolBarNumberOfItem() -> Int {
        let toobarHeaderData: [String] = getHeaderData(1)!
        return toobarHeaderData.count
    }

    func eqToolBar(titleOfItemAt: Int) -> String {
        let toobarHeaderData: [String] = getHeaderData(1)!
        return toobarHeaderData[titleOfItemAt]
    }

    func eqToolBar(didSelectAt: Int) {
        currentToolItemIndex = didSelectAt + 1
        if EQUserManager.shard.userStatus != .guest {
            loadEQDatas {
                [weak self] in
                self?.reloadUserPageData()
            }
        }
    }

    func scrollViewDidScroll(_: UIScrollView) {
        userTableView.fadeTopCell()
    }
}
