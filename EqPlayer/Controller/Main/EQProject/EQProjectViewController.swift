//
//  EQProjectViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import Charts
import RealmSwift
import UIKit
import PopupDialog
import SwipeCellKit

class EQProjectViewController: EQTableViewController {
  @IBOutlet var editTableView: UITableView!
  @IBOutlet var editBandView: EQEditBandView!
  @IBOutlet var editViewTopConstraint: NSLayoutConstraint!
  let eqSettingManager = EQSettingModelManager()
  var projectName: String = "專案"
  var oldContentOffset = CGPoint.zero
  let topConstraintRange = (CGFloat(-315) ..< CGFloat(25))
  //For reorder cell
  fileprivate var sourceIndexPath: IndexPath?
  fileprivate var snapshot: UIView?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    projectName = eqSettingManager.tempModel.name == "" ? "專案" : eqSettingManager.tempModel.name
    setupTableView()
    setupEditBandView()
    setCanPanToDismiss(true)
    generateSectionAndCell()
    subscribeNotification()
    setupLongPressOrderCell()
  }
  
  override func onDismiss() {
    popupAskUserToSave()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    removeNotification()
  }
  
  @objc func projectDidModify() {
    sessionOf(EQProjectSectionCell.trackHeaderWithCell.rawValue).cellDatas = Array(eqSettingManager.tempModel.tracks)
    editBandView.saveButton.setTitle("儲存", for: .normal)
    editTableView.reloadData()
  }
  
  @objc func projectAccidentallyClose() {
    if eqSettingManager.tempModel.tracks.count > 0 && eqSettingManager.tempModel.status != EQProjectModel.EQProjectStatus.saved {
      eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
      eqSettingManager.tempModel.name = projectName
      eqSettingManager.saveObjectTo(status: .temp)
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
    }
  }
  
  func save() {
    eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
    eqSettingManager.tempModel.name = projectName
    editBandView.projectNameLabel.text = projectName
    editBandView.saveButton.setTitle("編輯", for: .normal)
    eqSettingManager.saveObjectTo(status: .saved)
    EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
    dismiss(animated: true, completion: nil)
    
  }
  
  func popupAskUserToSave() {
    setDarkMode()
    if eqSettingManager.isModify && eqSettingManager.tempModel.tracks.count > 0 {
      let title = "尚未儲存"
      let message = "您的專案尚未儲存，確定直接關閉嗎。"
      
      let popup = PopupDialog(title: title, message: message, image: nil)
      popup.transitionStyle = .zoomIn
      popup.buttonAlignment = .horizontal
      let cancel = CancelButton(title: "繼續變更") {
        self.backToAppear()
      }
      let close = DefaultButton(title: "直接關閉", height: 60) {
        self.dismiss(animated: true, completion: nil)
      }
      
      switch eqSettingManager.tempModel.status {
      case .saved:
       
        let temp = DefaultButton(title: "儲存", height: 60) {
          self.save()
        }
        popup.addButtons([cancel,temp,close])
      case .temp:
        let temp = DefaultButton(title: "儲存施工專案", height: 60) {
          self.backToAppear()
          self.showSavePage()

        }
        popup.addButtons([cancel,temp,close])
      case .new:
        let temp = DefaultButton(title: "放入施工中", height: 60) {
          self.projectAccidentallyClose()
          self.dismiss(animated: true, completion: nil)
        }
        popup.addButtons([cancel,temp,close])
      }
      self.present(popup, animated: true, completion: nil)
    } else {
      dismiss(animated: true) {
        EQSpotifyManager.shard.playFromLastDuration()
      }
    }
    
  }
  
  func setupLongPressOrderCell() {
    let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(longPress:)))
    self.editTableView.addGestureRecognizer(longPress)
  }
  
  @objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
    let state = longPress.state
    let location = longPress.location(in: self.editTableView)
    guard let indexPath = self.editTableView.indexPathForRow(at: location) ?? sourceIndexPath ?? nil else {
      return
    }
    switch state {
    case .began:
      sourceIndexPath = indexPath
      guard let cell = self.editTableView.cellForRow(at: indexPath) else { return }
      snapshot = self.customSnapshotFromView(inputView: cell)
      guard  let snapshot = self.snapshot else { return }
      var center = cell.center
      snapshot.center = center
      snapshot.alpha = 0.0
      self.editTableView.addSubview(snapshot)
      UIView.animate(withDuration: 0.25, animations: {
        center.y = location.y
        snapshot.center = center
        snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        snapshot.alpha = 0.98
        cell.alpha = 0.0
      }, completion: { (finished) in
        cell.isHidden = true
      })
      
    case .changed:
      guard  let snapshot = self.snapshot else {
        return
      }
      var center = snapshot.center
      center.y = location.y
      snapshot.center = center
      guard let sourceIndexPath = self.sourceIndexPath  else {
        return
      }
      if indexPath != sourceIndexPath {
        swap(&eqSettingManager.tempModel.tracks[indexPath.row], &eqSettingManager.tempModel.tracks[sourceIndexPath.row])
        self.editTableView.moveRow(at: sourceIndexPath, to: indexPath)
        self.sourceIndexPath = indexPath
      }
    default:
      guard let cell = self.editTableView.cellForRow(at: indexPath) else {
        return
      }
      guard  let snapshot = self.snapshot else {
        return
      }
      cell.isHidden = false
      cell.alpha = 0.0
      UIView.animate(withDuration: 0.25, animations: {
        snapshot.center = cell.center
        snapshot.transform = CGAffineTransform.identity
        snapshot.alpha = 0
        cell.alpha = 1
      }, completion: { (finished) in
        self.cleanup()
      })
      break
    }
  }
  
  private func cleanup() {
    self.sourceIndexPath = nil
    snapshot?.removeFromSuperview()
    self.snapshot = nil
  }
  
  
  private func customSnapshotFromView(inputView: UIView) -> UIView? {
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
    if let currentContext = UIGraphicsGetCurrentContext() {
      inputView.layer.render(in: currentContext)
    }
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      UIGraphicsEndImageContext()
      return nil
    }
    UIGraphicsEndImageContext()
    let snapshot = UIImageView(image: image)
    snapshot.layer.masksToBounds = false
    snapshot.layer.cornerRadius = 0
    snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
    snapshot.layer.shadowRadius = 5
    snapshot.layer.shadowOpacity = 0.4
    return snapshot
  }
  
  func subscribeNotification() {
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectDidModify), notification: Notification.Name.eqProjectTrackModifyNotification)
    EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectAccidentallyClose), notification: Notification.Name.eqProjectAccidentallyClose)
  }
  
  func removeNotification() {
    EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectTrackModifyNotification)
    EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectAccidentallyClose)
  }
  
  func setupEditBandView() {
    editBandView.delegate = self
    editBandView.lineChartView.delegate = self
    
    editBandView.projectNameLabel.text = projectName
  }
  
  func setupTableView() {
    editTableView.contentInsetAdjustmentBehavior = .never
    editTableView.delegate = self
    editTableView.dataSource = self
    editTableView.separatorStyle = .none
  }
}

extension EQProjectViewController: ChartViewDelegate {
  func chartEntryDrag(_: ChartViewBase, entry dragEntry: ChartDataEntry) {
    // Set band
    print(dragEntry.y)
    EQSpotifyManager.shard.setGain(value: Float(dragEntry.y), atBand: UInt32(dragEntry.x))
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let delta = scrollView.contentOffset.y - oldContentOffset.y
    
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
    editTableView.fadeTopCell()
  }
  
}

extension EQProjectViewController: EQEditBandViewDelegate, EQSaveProjectViewControllerDelegate {
  
  func setDarkMode() {
    let pv = PopupDialogDefaultView.appearance()
    pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
    pv.titleColor   = .white
    pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
    pv.messageColor = UIColor(white: 0.8, alpha: 1)
    
    let pcv = PopupDialogContainerView.appearance()
    pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
    pcv.cornerRadius    = 2
    pcv.shadowEnabled   = true
    pcv.shadowColor     = .black
    
    let ov = PopupDialogOverlayView.appearance()
    ov.blurEnabled     = true
    ov.blurRadius      = 30
    ov.liveBlurEnabled = true
    ov.opacity         = 0.3
    ov.color           = .black
    let db = DefaultButton.appearance()
    db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
    db.titleColor     = .white
    db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
    db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    
    let cb = CancelButton.appearance()
    cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
    cb.titleColor     = UIColor(white: 0.6, alpha: 1)
    cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
    cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
  }
  func didClickDismissButton() {
    popupAskUserToSave()
  }
  
  func didClickSaveButton(projectName: String) {
    print((Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)! + "---------------")
    if eqSettingManager.tempModel.tracks.count <= 0 {
      return
    }
    self.projectName = projectName
    save()
  }
  
  func didClickSaveProjectButton() {
    showSavePage()
  }
  
  func didClickPostProjectButton() {
  }
  func showSavePage(){
    if let saveProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(
      withIdentifier: String(describing: EQSaveProjectViewController.self)) as? EQSaveProjectViewController {
      saveProjectViewController.modalPresentationStyle = .overCurrentContext
      saveProjectViewController.modalTransitionStyle = .crossDissolve
      saveProjectViewController.delegate = self
      saveProjectViewController.originalProjectName = projectName
      present(saveProjectViewController, animated: true, completion: nil)
    }
  }
}
extension EQProjectViewController: SwipeTableViewCellDelegate{
  func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    let track = eqSettingManager.tempModel.tracks[indexPath.row]
    guard orientation == .right else {
      return nil
    }
    let swipeAction = SwipeAction(style: .default, title: "") { _, _ in
      self.eqSettingManager.tempModel.tracks.remove(at: indexPath.row)
      self.eqSettingManager.isModify = true
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
    }
    swipeAction.image = UIImage(named: "remove")
    swipeAction.backgroundColor = UIColor.clear
    return [swipeAction]
  }
  func tableView(_: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for _: SwipeActionsOrientation) -> SwipeTableOptions {
    var options = SwipeTableOptions()
    options.backgroundColor = UIColor(red: 1, green: 38 / 255, blue: 0, alpha: 0.3)
    options.expansionStyle = .selection
    options.transitionStyle = .reveal
    options.buttonVerticalAlignment = .center
    return options
  }
}

