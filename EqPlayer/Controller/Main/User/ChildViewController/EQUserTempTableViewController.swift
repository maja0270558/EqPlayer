//
//  EQUserTempTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQUserTempTableViewController: EQProjectTableViewController {
  @IBOutlet weak var tableView: UITableView!
  var topInset: CGFloat = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    setupReuseCellType(typeName: EQSaveProjectCell.typeName, tableView: tableView)
    setupTableView()
    loadDataFromRealm()
  }
  func setupTableView() {
    tableView.contentInset.top = topInset
    tableView.delegate = self
    tableView.dataSource = self
    tableView.separatorStyle = .none
    
  }
  func loadDataFromRealm(){
    let data: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "status == %@", value: EQProjectStatus.temp.rawValue)
    projectData = data
  }
  
  override func configCell(data: EQProjectModelProtocol, cell: UITableViewCell, indexPath: IndexPath) {
    guard let eqModel = data as? EQProjectModel,
      let postCell = cell as? EQSaveProjectCell,
     let userVC = self.parent as? EQUserViewController else {
        return
    }
    postCell.delegate = userVC
    postCell.cellIndexPath = indexPath
    let buttonImage = eqModel.status == EQProjectStatus.temp ? UIImage(named: "wrench") : UIImage(named: "play")
    postCell.projectTitleLabel.text = eqModel.name
    postCell.cellIndicator.startAnimating()
    postCell.trackCountLabel.text = String(eqModel.tracks.count)
    postCell.playbutton.setBackgroundImage(buttonImage, for: .normal)
    let imageURLs = eqModel.tracks.map {
      $0.coverURL!
    }
    postCell.cellEQChartView.alpha = 0
    postCell.cellEQChartView.isUserInteractionEnabled = false
    
    postCell.setDiscsImage(imageURLs: Array(imageURLs)) {
      let color = self.getProperColor(color: (postCell.discImageLarge.image?.getPixelColor(postCell.discImageLarge.center))!)
      postCell.cellEQChartView.setChart(15, color: color, style: .cell)
      postCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
      postCell.cellIndicator.stopAnimating()
      UIView.animate(withDuration: 0.3, animations: {
        postCell.cellEQChartView.alpha = 1
      })
    }
  }
  override func reloadTableView() {
    loadDataFromRealm()
    tableView.reloadData()
  }
}
