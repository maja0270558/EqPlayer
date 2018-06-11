//
//  EQProjectViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import Charts
import PopupDialog
import RealmSwift
import SwipeCellKit
import UIKit

class EQProjectViewController: EQTrackTableViewController {
    @IBOutlet var editTableView: UITableView!
    @IBOutlet var editBandView: EQEditBandView!
    @IBOutlet var topParentView: UIView!
    @IBOutlet var addTrackView: EQSaveProjectPageAddTrackHeader!
    var projectName: String = "專案"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAddTrackView()
        setupEditBandView()
        controllerInit()
    }

    func controllerInit() {
        setupTableView(typeName: EQSonglistTableViewCell.typeName, tableView: editTableView)
        tableViewData = Array(eqSettingManager.tempModel.tracks)
        editTableView.contentInset.top = topParentView.bounds.height
        subscribeNotification()
        setCanPanToDismiss(true)
    }

    func setupAddTrackView() {
        addTrackView.addTrack = { [weak self] in
            if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateInitialViewController() as? EQSelectTrackViewController {
                playlistViewController.modalPresentationStyle = .overCurrentContext
                playlistViewController.modalTransitionStyle = .crossDissolve
                playlistViewController.eqSettingManager = (self?.eqSettingManager)!
                self?.present(playlistViewController, animated: true, completion: nil)
            }
        }
    }

    override func onDismiss() {
        popupAskUserToSave()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
    }

    @objc func projectDidModify() {
        tableViewData = Array(eqSettingManager.tempModel.tracks)
        editBandView.saveButton.setTitle("儲存", for: .normal)
        editTableView.reloadData()
    }

    @objc func projectAccidentallyClose() {
        if eqSettingManager.tempModel.tracks.count > 0 && eqSettingManager.tempModel.status != EQProjectStatus.saved {
            eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
            eqSettingManager.tempModel.name = projectName
            eqSettingManager.saveObjectTo(status: .temp)
            EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
        }
    }

    @objc func projectChildControllerPreviewDidClick() {
        reloadTrack()
    }

    func save() {
        eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
        eqSettingManager.tempModel.name = projectName
        editBandView.projectNameTextField.text = projectName
        editBandView.saveButton.setTitle("編輯", for: .normal)
        eqSettingManager.saveObjectTo(status: .saved)
        eqSettingManager.tempModel.status = .saved
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
        backToMain()
    }

    func post(description: String) {
        eqSettingManager.tempModel.name = projectName
        editBandView.projectNameTextField.text = projectName
        eqSettingManager.tempModel.status = .post
        eqSettingManager.tempModel.detailDescription = description
        EQFirebaseManager.postEQProject(projectModel: eqSettingManager.tempModel)
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectSave)
        backToMain()
    }

    func popupAskUserToSave() {
        EQAlertViewControllerSetting.setDarkMode()
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
                self.backToMain()
            }

            switch eqSettingManager.tempModel.status {
            case .saved, .post:

                let temp = DefaultButton(title: "儲存", height: 60) {
                    self.save()
                }
                popup.addButtons([cancel, temp, close])
            case .temp:
                let temp = DefaultButton(title: "儲存施工專案", height: 60) {
                    self.backToAppear()
                    self.showSavePage(isPost: false)
                }
                popup.addButtons([cancel, temp, close])
            case .new:
                let temp = DefaultButton(title: "放入施工中", height: 60) {
                    self.projectAccidentallyClose()
                    self.dismiss(animated: true, completion: nil)
                }
                popup.addButtons([cancel, temp, close])
            case .post:
                break
            }
            present(popup, animated: true, completion: nil)
        } else {
            backToMain()
        }
    }

    func backToMain() {
        dismiss(animated: true) {
            EQSpotifyManager.shard.resetPreviewURL()
            EQSpotifyManager.shard.playFromLastDuration()
            EQSpotifyManager.shard.setGain(setting: EQSpotifyManager.shard.currentSetting)
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        let finalOffset = -offset - topParentView.bounds.height
        topParentView.frame.origin.y = finalOffset
        if offset > -addTrackView.bounds.height {
            topParentView.frame.origin.y = -topParentView.bounds.height + addTrackView.bounds.height
        }
        editTableView.fadeTopCell()
    }

    func subscribeNotification() {
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectDidModify), notification: Notification.Name.eqProjectTrackModifyNotification)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectAccidentallyClose), notification: Notification.Name.eqProjectAccidentallyClose)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectChildControllerPreviewDidClick), notification: Notification.Name.eqProjectPlayPreviewTrack)
    }

    func removeNotification() {
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectTrackModifyNotification)
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectAccidentallyClose)
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectPlayPreviewTrack)
    }

    func setupEditBandView() {
        projectName = eqSettingManager.tempModel.name == "" ? "專案" : eqSettingManager.tempModel.name
        editBandView.lineChartView.setEntryValue(yValues: Array(eqSettingManager.tempModel.eqSetting))
        editBandView.delegate = self
        editBandView.lineChartView.delegate = self
        editBandView.projectNameTextField.text = projectName
        eqSettingManager.setEQSetting(values: editBandView.lineChartView.getEntryValues())
    }
}

extension EQProjectViewController: ChartViewDelegate {
    func chartEntryDrag(_: ChartViewBase, entry dragEntry: ChartDataEntry) {
        // Set band
        eqSettingManager.isModify = true
        eqSettingManager.tempModel.eqSetting[Int(dragEntry.x)] = dragEntry.y
        editBandView.saveButton.setTitle("儲存", for: .normal)
        EQSpotifyManager.shard.setGain(value: Float(dragEntry.y), atBand: UInt32(dragEntry.x))
    }
}

extension EQProjectViewController: EQEditBandViewDelegate, EQSaveProjectViewControllerDelegate {
    func didClickDismissButton() {
        popupAskUserToSave()
    }

    func didClickSaveButton(projectName: String, description: String, isPost: Bool) {
        print((Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)! + "---------------")

        if eqSettingManager.tempModel.tracks.count <= 0 {
            return
        }
        self.projectName = projectName
        if isPost {
            post(description: description)
        } else {
            save()
        }
    }

    func didClickSaveProjectButton() {
        showSavePage(isPost: false)
    }

    func didClickPostProjectButton() {
        showSavePage(isPost: true)
    }

    func showSavePage(isPost: Bool) {
        if eqSettingManager.tempModel.tracks.count > 0 {
            if let saveProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(
                withIdentifier: String(describing: EQSaveProjectViewController.self)) as? EQSaveProjectViewController {
                saveProjectViewController.controllerIsUseToPost = isPost
                saveProjectViewController.modalPresentationStyle = .overCurrentContext
                saveProjectViewController.modalTransitionStyle = .crossDissolve
                saveProjectViewController.delegate = self
                saveProjectViewController.originalProjectName = editBandView.projectNameTextField.text!
                present(saveProjectViewController, animated: true, completion: nil)
            }
        }
    }
}
