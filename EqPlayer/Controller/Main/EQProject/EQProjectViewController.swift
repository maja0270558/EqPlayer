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

class EQProjectViewController: EQTableViewController {
    @IBOutlet var editTableView: UITableView!
    @IBOutlet var editBandView: EQEditBandView!
    @IBOutlet var editViewTopConstraint: NSLayoutConstraint!
    let eqSettingManager = EQSettingModelManager()
    var projectName: String = "Project"
    var oldContentOffset = CGPoint.zero
    let topConstraintRange = (CGFloat(-315) ..< CGFloat(25))
    //For reorder cell
    fileprivate var sourceIndexPath: IndexPath?
    fileprivate var snapshot: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        projectName = eqSettingManager.tempModel.name == "" ? "Project" : eqSettingManager.tempModel.name
        setupTableView()
        setupEditBandView()
        setCanPanToDismiss(true)
        generateSectionAndCell()
        subscribeNotification()
        setupLongPressOrderCell()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
    }

    @objc func projectDidModify() {
        sessionOf(EQProjectSectionCell.trackHeaderWithCell.rawValue).cellDatas = Array(eqSettingManager.tempModel.tracks)
        editBandView.saveButton.setTitle("Save", for: .normal)
        editBandView.projectNameLabel.text = projectName + " (unsave)"
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

    func setupLongPressOrderCell() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureRecognized(longPress:)))
        self.editTableView.addGestureRecognizer(longPress)
    }
  
    @objc func longPressGestureRecognized(longPress: UILongPressGestureRecognizer) {
        let state = longPress.state
        let location = longPress.location(in: self.editTableView)
        let indexPath = self.editTableView.indexPathForRow(at: location) ?? sourceIndexPath!
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
    func didClickSaveButton(projectName: String) {
        print((Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)! + "---------------")
        if eqSettingManager.tempModel.tracks.count <= 0 {
            return
        }
        self.projectName = projectName
        eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
        eqSettingManager.tempModel.name = projectName
        editBandView.projectNameLabel.text = projectName
        editBandView.saveButton.setTitle("Edit", for: .normal)
        eqSettingManager.saveObjectTo(status: .saved)
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
        dismiss(animated: true, completion: nil)
    }

    func didClickSaveProjectButton() {
        if let saveProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(
            withIdentifier: String(describing: EQSaveProjectViewController.self)) as? EQSaveProjectViewController {
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
