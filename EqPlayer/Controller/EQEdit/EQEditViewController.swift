//
//  EQEditViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
import RealmSwift
class EQEditViewController: EQTableViewController {
    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var eqEditView: EQEditChartView!
    
    let eqSettingManager = EQSettingModelManager()
    var sections: [EQEditTableViewGenerator] = [.addTrackHeader]
    var projectName:String = "Project"
    var oldContentOffset = CGPoint.zero
    let topConstraintRange = (CGFloat(-315)..<CGFloat(25))
    
    @IBOutlet weak var editViewTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        canPan = true
        setupTableView()
        createSectionAndCells()
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(projectDidModify), notification: Notification.Name.eqProjectTrackModifyNotification)
        eqEditView.delegate = self
        eqEditView.projectNameLabel.text = self.projectName
        
    }
    @objc func projectDidModify() {
        sectionProviders[0].cellDatas = Array(eqSettingManager.tempModel.tracks)
        eqEditView.saveButton.setTitle("Save", for: .normal)
        eqEditView.projectNameLabel.text = projectName + " (unsave)"
        editTableView.reloadData()
    }
    func createSectionAndCells(){
        sectionProviders = generateSectionAndCell(providerTypes: sections)
    }
    func setupTableView() {
        editTableView.contentInsetAdjustmentBehavior = .never
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.separatorStyle = .none
    }
}
extension EQEditViewController: ChartViewDelegate {
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
extension EQEditViewController: EQEditChartViewDelegate, EQEditProjectNameViewControllerDelegate {
    func saveOnClick(projectName: String) {
        print((Realm.Configuration.defaultConfiguration.fileURL?.absoluteString)! + "---------------")
        self.projectName = projectName
        eqSettingManager.tempModel.name = projectName
        eqEditView.projectNameLabel.text = projectName
        eqEditView.saveButton.setTitle("Edit", for: .normal)
        eqSettingManager.saveObjectTo(status: .saved)
    }
    
    func saveButtonDidClick() {
        if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQEditProjectNameViewController.self)) as? EQEditProjectNameViewController {
            playlistViewController.modalPresentationStyle = .overCurrentContext
            playlistViewController.modalTransitionStyle = .crossDissolve
            playlistViewController.delegate = self
            playlistViewController.originalProjectName = projectName
            present(playlistViewController, animated: true, completion: nil)
        }
    }
    
    func postButtonDidClick() {
        
    }
}
