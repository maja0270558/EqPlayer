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
  var barData = ["Posted", "Saved", "Liked"]
  var eqDatas = [EQProjectModel]()
  @IBOutlet var userTableView: UITableView!
  
  override func viewDidLoad() {
    setupTableView()
    loadEQDatas()
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
    eqDatas = data
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
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    userTableView.fadeTopCell()
  }
}
