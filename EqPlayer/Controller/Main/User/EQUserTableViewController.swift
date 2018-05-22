//
//  EQUserTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQUserTableViewController: EQTableViewController {
  var icon: UIImage?
  var sections: [EQUserTableViewControllerSectionAndCellProvider] = [.userInfoCell, .toolBar]
  var barData = ["Saved", "Post", "Panding"]
  var eqData = [EQProjectModel]()
  var unsaveEQData = [EQProjectModel]()
  var postedEQData = [EQProjectModel]()
  var currentToolItemIndex: Int = 1
  @IBOutlet var userTableView: UITableView!
  
  override func viewDidLoad() {
    setupTableView()
    loadEQDatas()
    subscribeNotification()
    generateSectionAndCell()
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
  }
  @objc func didSaveEQProject(){
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
    currentToolItemIndex = didSelectAt+1
    reloadUserPageData()
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    userTableView.fadeTopCell()
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
  }
}


