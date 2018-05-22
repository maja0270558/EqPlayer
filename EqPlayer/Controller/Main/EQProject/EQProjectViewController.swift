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
        editBandView.saveButton.setTitle("Save", for: .normal)
        editBandView.projectNameLabel.text = projectName + " (unsave)"
        editTableView.reloadData()
    }
    @objc func projectAccidentallyClose() {
      if eqSettingManager.tempModel.tracks.count > 0 {
        eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
        eqSettingManager.tempModel.name = projectName
        eqSettingManager.saveObjectTo(status: .temp)
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
      }
    }

    func subscribeNotification() {
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectDidModify), notification: Notification.Name.eqProjectTrackModifyNotification)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectAccidentallyClose), notification: Notification.Name.eqProjectAccidentallyClose)
    }

    func setupEditBandView() {
        editBandView.delegate = self
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
    func chartEntryDrag(_: ChartViewBase, entry _: ChartDataEntry) {
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
        self.projectName = projectName
        eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
        eqSettingManager.tempModel.name = projectName
        editBandView.projectNameLabel.text = projectName
        editBandView.saveButton.setTitle("Edit", for: .normal)
        eqSettingManager.saveObjectTo(status: .saved)
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
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
