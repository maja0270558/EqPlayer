//
//  EQProjectViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
class EQProjectViewController: EQTableViewController {
  
  @IBOutlet weak var editTableView: UITableView!
  @IBOutlet weak var eqEditView: EQEditChartView!
  @IBOutlet weak var editViewTopConstraint: NSLayoutConstraint!
  let eqSettingManager = EQSettingModelManager()
  var projectName:String = "Project"
  var oldContentOffset = CGPoint.zero
  let topConstraintRange = (CGFloat(-315)..<CGFloat(25))
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupEditBandView()
    setCanPanToDismiss(true)
    generateSectionAndCell()
    subscribeNotification()
  }
  
  @objc func projectDidModify() {
    sessionOf(EQProjectSectionCell.trackHeaderWithCell.rawValue).cellDatas = Array(eqSettingManager.tempModel.tracks)
    eqEditView.saveButton.setTitle("Save", for: .normal)
    eqEditView.projectNameLabel.text = projectName + " (unsave)"
    editTableView.reloadData()
  }
  
  func subscribeNotification(){
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectDidModify), notification: Notification.Name.eqProjectTrackModifyNotification)
  }
  
  func setupEditBandView() {
    eqEditView.delegate = self
    eqEditView.projectNameLabel.text = self.projectName
  }
  
  func setupTableView() {
    editTableView.contentInsetAdjustmentBehavior = .never
    editTableView.delegate = self
    editTableView.dataSource = self
    editTableView.separatorStyle = .none
  }
}
extension EQProjectViewController: ChartViewDelegate {
  func chartEntryDrag(_ chartView: ChartViewBase, entry: ChartDataEntry) {
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let delta =  scrollView.contentOffset.y - oldContentOffset.y
    
    if delta < 0 && (editViewTopConstraint.constant) <= topConstraintRange.upperBound && scrollView.contentOffset.y < 0 {
      editViewTopConstraint.constant -= delta
      scrollView.contentOffset.y -= delta
    } else if scrollView.contentOffset.y < 0 {
      editViewTopConstraint.constant = -delta + topConstraintRange.upperBound
      return
    }
    
    if delta > 0 && (editViewTopConstraint.constant - delta) > topConstraintRange.lowerBound && scrollView.contentOffset.y > 0 {
      editViewTopConstraint.constant -= delta
      scrollView.contentOffset.y -= delta
    }
    
    oldContentOffset = scrollView.contentOffset
    self.editTableView.fadeTopCell()
  }
}
extension EQProjectViewController: EQEditChartViewDelegate, EQSaveProjectViewControllerDelegate {
  func didClickSaveButton(projectName: String) {
    print((Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)! + "---------------")
    self.projectName = projectName
    eqSettingManager.tempModel.name = projectName
    eqEditView.projectNameLabel.text = projectName
    eqEditView.saveButton.setTitle("Edit", for: .normal)
    eqSettingManager.saveObjectTo(status: .saved)
  }
  
  func didClickSaveProjectButton() {
    if let saveProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQSaveProjectViewController.self)) as? EQSaveProjectViewController {
      saveProjectViewController.modalPresentationStyle = .overCurrentContext
      saveProjectViewController.modalTransitionStyle = .crossDissolve
      saveProjectViewController.delegate = self
      saveProjectViewController.originalProjectName = projectName
      present(saveProjectViewController, animated: true, completion: nil)
    }
  }
  
  func didClickPostProjectButton() {
    
  }
}
