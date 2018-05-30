//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol EQUserTableViewControllerDelegate: class {
    func didSelectUserCell(type: UserToolBarProvider, data: EQProjectModel)
    func didPressMoreOptionEditButton(at: IndexPath, data: EQProjectModel)
    func didPressMoreOptionDeleteButton(at: IndexPath, data: EQProjectModel)
}

class EQUserTableViewController: EQTableViewController {
    weak var delegate: EQUserTableViewControllerDelegate?
    var icon: UIImage?
    var sections: [EQUserTableViewControllerSectionAndCellProvider] = [.userInfoCell, .toolBar]
  
    var eqData = [EQProjectModel]()
    var unsaveEQData = [EQProjectModel]()
    var postedEQData = [EQProjectModel]()
  
    var userPageData = [UserToolBarProvider: [EQProjectModel]]()
  
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
        userPageData[UserToolBarProvider.saved] = data
        userPageData[UserToolBarProvider.temp] = tempData
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
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if indexPath.section != 1 || EQUserManager.shard.userStatus == .guest {
      return
    }
    guard let indexType = UserToolBarProvider(rawValue: currentToolItemIndex) else {
      return
    }
    delegate?.didSelectUserCell(type: indexType, data: getTargetModelCopy(at: indexPath))
  }
  
  func getTargetModelCopy(at: IndexPath) -> EQProjectModel {
    
    guard let indexType = UserToolBarProvider(rawValue: currentToolItemIndex), let datas = userPageData[indexType] else {
      return EQProjectModel()
    }
    return EQProjectModel(value: datas[at.row])
    }
  
  func reloadUserPageData() {
    loadEQDatas()
    guard let indexType = UserToolBarProvider(rawValue: currentToolItemIndex), let datas = userPageData[indexType] else {
      return
    }
    sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas = datas
    let newCount = sessionOf(EQUserTableViewControllerSectionAndCellProvider.toolBar.rawValue).cellDatas.count
    let oldCount = userTableView.numberOfRows(inSection: 1)
    userTableView.reloadRowsInSection(section: 1, oldCount: oldCount, newCount: newCount)
  }
}
