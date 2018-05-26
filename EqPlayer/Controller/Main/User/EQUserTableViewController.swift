//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol EQUserTableViewControllerDelegate: class {
    func didSelectTempEQCellRow(at: IndexPath, data: EQProjectModel)
    func didSelectSavedEQCellRow(at: IndexPath, data: EQProjectModel)
    func didSelectPostedEQCellRow(at: IndexPath, data: EQProjectModel)
    func didPressMoreOptionEditButton(at: IndexPath, data: EQProjectModel)
    func didPressMoreOptionDeleteButton(at: IndexPath, data: EQProjectModel)
}

class EQUserTableViewController: EQTableViewController {
    weak var delegate: EQUserTableViewControllerDelegate?
    var icon: UIImage?
    var sections: [EQUserTableViewControllerSectionAndCellProvider] = [.userInfoCell, .toolBar]
    var barData = ["已儲存", "已發布", "施工中"]
    var eqData = [EQProjectModel]()
    var unsaveEQData = [EQProjectModel]()
    var postedEQData = [EQProjectModel]()
    var currentToolItemIndex: Int = 1
    var operationDictionary: [IndexPath: BlockOperation] = [IndexPath: BlockOperation]()
    let queue = OperationQueue()

    @IBOutlet var userTableView: UITableView!

    override func viewDidLoad() {
        setupTableView()
        loadEQDatas()
        subscribeNotification()
        generateSectionAndCell()
    }

    override func viewWillDisappear(_: Bool) {
        removeNotification()
    }

    func setupTableView() {
        userTableView.contentInsetAdjustmentBehavior = .never
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.separatorStyle = .none
    }

    func loadEQDatas() {
        let data: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "status == %@", value: EQProjectModel.EQProjectStatus.saved.rawValue)
        let tempData: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "status == %@", value: EQProjectModel.EQProjectStatus.temp.rawValue)
        unsaveEQData = tempData
        eqData = data
    }

    func subscribeNotification() {
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didSaveEQProject), notification: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didSaveEQProject), notification: Notification.Name.eqProjectDelete)
    }

    func removeNotification() {
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectDelete)
    }

    @objc func didSaveEQProject() {
        reloadUserPageData()
    }

    func reloadUserPageData() {
        loadEQDatas()
        switch currentToolItemIndex {
        case 1:
            sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas = eqData
        case 2:
            sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas = postedEQData
        case 3:
            sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas = unsaveEQData
        default:
            break
        }
        let newCount = sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas.count
        let oldCount = userTableView.numberOfRows(inSection: 1)
        userTableView.reloadRowsInSection(section: 1, oldCount: oldCount, newCount: newCount)
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
        currentToolItemIndex = didSelectAt + 1
        reloadUserPageData()
    }

    func scrollViewDidScroll(_: UIScrollView) {
        userTableView.fadeTopCell()
    }

    func getTargetModelCopy(at: IndexPath) -> EQProjectModel {
        if at.section != 1 {
            return EQProjectModel()
        }
        switch currentToolItemIndex {
        case 1:
            return EQProjectModel(value: eqData[at.row])
        case 2:
            return EQProjectModel(value: postedEQData[at.row])
        case 3:
            return EQProjectModel(value: unsaveEQData[at.row])
        default:
            return EQProjectModel()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section != 1 {
            return
        }
        switch currentToolItemIndex {
        case 1:
            // pop player
            delegate?.didSelectSavedEQCellRow(at: indexPath, data: getTargetModelCopy(at: indexPath))
        case 2:
            // nothing
            delegate?.didSelectPostedEQCellRow(at: indexPath, data: getTargetModelCopy(at: indexPath))
        case 3:
            // pop setter
            delegate?.didSelectTempEQCellRow(at: indexPath, data: getTargetModelCopy(at: indexPath))
        default:
            break
        }
    }
}

extension EQUserTableViewController: EQSaveProjectCellDelegate {
    func didClickMoreOptionButton(indexPath: IndexPath) {
        moreOptionAlert(
            delete: { [weak self] _ in
                self?.delegate?.didPressMoreOptionDeleteButton(at: indexPath, data: (self?.getTargetModelCopy(at: indexPath))!)
            }, edit: { [weak self] _ in
                self?.delegate?.didPressMoreOptionEditButton(at: indexPath, data: (self?.getTargetModelCopy(at: indexPath))!)
        })
    }
}
