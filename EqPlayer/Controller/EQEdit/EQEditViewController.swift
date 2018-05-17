//
//  EQEditViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
class EQEditViewController: EQTableViewController {
    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var eqEditView: EQEditChartView!
    var sections: [EQEditTableViewGenerator] = [.addTrackHeader]
    var barData = [SPTTrack]()
    var oldContentOffset = CGPoint.zero
    let topConstraintRange = (CGFloat(-315)..<CGFloat(25))
    
    @IBOutlet weak var editViewTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        createSectionAndCells()
        eqEditView.delegate = self
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
extension EQEditViewController: EQEditChartViewDelegate {
    func saveButtonDidClick() {
        if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQEditProjectNameViewController.self)) as? EQEditProjectNameViewController {
            playlistViewController.modalPresentationStyle = .overCurrentContext
            playlistViewController.modalTransitionStyle = .crossDissolve
            present(playlistViewController, animated: true, completion: nil)
        }
    }
    
    func postButtonDidClick() {
        
    }
}
