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
import UIKit

class EQProjectViewController: EQTrackTableViewController {
    @IBOutlet var editBandView: EQEditBandView!
    @IBOutlet var topParentView: UIView!
    @IBOutlet var addTrackView: EQSaveProjectPageAddTrackHeader!
    @IBOutlet weak var defaultSettingCollectionView: UICollectionView!
    
    var childViewModel: EQProjectViewControllerViewModelProtocol!
    
    override var parentViewModel: EQTrackTableViewModelProtocol! {
        get {
            return childViewModel
        }
    }
    
    override func buildViewModel(_ projectModel: EQSettingModelManager!, withTracks tracks: NSMutableArray!, isProjectController isProjectVC: Bool) {
        childViewModel = EQProjectViewControllerViewModel(eqSettingManager: projectModel, andTracks: tracks, isProjectController: isProjectVC)
    }
    
    let templates = EQDefaultSettings()
    let settingIdentifier = "DefaultSettingCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controllerInit()
        setupAddTrackView()
        setupEditBandView()
        setupDefaultSettingCollectionView()
    }
    
    override func onDismiss() {
        popupAskUserToSave()
    }
    
    func controllerInit() {
        tableView.contentInset.top = topParentView.bounds.height
        subscribeNotification()
        enablePan(toDismiss: true)
    }
    
    func setupDefaultSettingCollectionView(){
        defaultSettingCollectionView.dataSource = self
        defaultSettingCollectionView.delegate = self
        let nib = UINib(nibName: settingIdentifier, bundle: nil)
        defaultSettingCollectionView.register(nib, forCellWithReuseIdentifier: settingIdentifier)
        if let flowlayout = defaultSettingCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowlayout.estimatedItemSize = CGSize(width: 1.1, height: 1.1)
        }
    }
    
    func setupAddTrackView() {
        addTrackView.addTrack = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            if let selectTrackViewController = UIStoryboard.eqProjectStoryBoard().instantiateInitialViewController() as? EQSelectTrackViewController {
                selectTrackViewController.modalPresentationStyle = .overCurrentContext
                selectTrackViewController.modalTransitionStyle = .crossDissolve
                selectTrackViewController.eqSettingManager = strongSelf.childViewModel.projectModel
                strongSelf.present(selectTrackViewController, animated: true, completion: nil)
            }
        }
    }
    
    func setupEditBandView() {
        editBandView.lineChartView.setEntryValue(yValues: Array(parentViewModel.projectModel.tempModel.eqSetting))
        editBandView.delegate = self
        editBandView.lineChartView.delegate = self
        editBandView.projectNameTextField.text = childViewModel.projectName()
        childViewModel.projectModel.setEQSetting(values: editBandView.lineChartView.getEntryValues())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
    }
    
    @objc func projectDidModify() {
        childViewModel.updateProjectTrack()
        editBandView.saveButton.setTitle(childViewModel.saveButtonTitle(), for: .normal)
    }
    
    @objc func projectAccidentallyClose() {
        childViewModel.save(Int32(EQProjectStatus.temp.rawValue), withDescribe: "")
    }
    
    @objc func projectChildControllerPreviewDidClick() {
        tableView.reloadDataUpdateFade()
    }
    
    func save() {
        editBandView.projectNameTextField.text = childViewModel.projectName()
        editBandView.saveButton.setTitle("編輯", for: .normal)
        childViewModel.save(Int32(EQProjectStatus.saved.rawValue), withDescribe: "")
        backToMain()
    }
    
    func post(description: String) {
        editBandView.projectNameTextField.text = childViewModel.projectName()
        childViewModel.save(Int32(EQProjectStatus.post.rawValue), withDescribe: description)
        backToMain()
    }
    
    
    // Third Party Framework
    func popupAskUserToSave() {
        EQAlertViewControllerSetting.setDarkMode()
        if parentViewModel.projectModel.isModify && parentViewModel.projectModel.tempModel.tracks.count > 0 {
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
            switch parentViewModel.projectModel.tempModel.status {
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
            }
            present(popup, animated: true, completion: nil)
        } else {
            backToMain()
        }
    }
    
    func backToMain() {
        dismiss(animated: true) {
            self.childViewModel.resetAllEQSetting()
        }
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === defaultSettingCollectionView { return }
        let offset = scrollView.contentOffset.y
        let finalOffset = -offset - topParentView.bounds.height
        topParentView.frame.origin.y = finalOffset
        if offset > -addTrackView.bounds.height {
            topParentView.frame.origin.y = -topParentView.bounds.height + addTrackView.bounds.height
        }
        tableView.fadeTopCell()
    }
}

extension EQProjectViewController: ChartViewDelegate {
    func chartEntryDrag(_: ChartViewBase, entry dragEntry: ChartDataEntry) {
        childViewModel.settingEQ(at: Int32(dragEntry.x), andGiveValue: dragEntry.y)
        editBandView.saveButton.setTitle("儲存", for: .normal)
    }
}

extension EQProjectViewController: EQEditBandViewDelegate, EQSaveProjectViewControllerDelegate {
    func didClickDismissButton() {
        popupAskUserToSave()
    }
    
    func didClickSaveButton(projectName: String, description: String, isPost: Bool) {
        childViewModel.setProjectName(projectName)
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
        print(editBandView.lineChartView.getEntryValues())
        if parentViewModel.projectModel.tempModel.tracks.count > 0 {
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

extension EQProjectViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        editBandView.lineChartView.setEntryValue(yValues: templates.settings[indexPath.row].setting)
        EQSpotifyManager.shard.setGain(setting: templates.settings[indexPath.row].setting)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return templates.settings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = defaultSettingCollectionView.dequeueReusableCell(withReuseIdentifier: settingIdentifier, for: indexPath) as? DefaultSettingCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.settingTitle.text = templates.settings[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
