//
//  EQUserSavedTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQUserSavedTableViewController: EQProjectTableViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var guestView: UIView!
    @IBAction func backToLoginPageAction(_: UIButton) {
        AppDelegate.shard?.switchToLoginStoryBoard()
    }

    var topInset: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReuseCellType(typeName: EQSaveProjectCell.typeName, tableView: tableView)
        setupTableView()
        if EQUserManager.shard.userStatus == .guest {
            guestView.isHidden = false
            return
        }

        loadDataFromRealm()
    }

    func setupTableView() {
        tableView.contentInset.top = topInset
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    func loadDataFromRealm() {
        let data: [EQProjectModel] = EQRealmManager.shard.findWithFilter(filter: "status == %@", value: EQProjectStatus.saved.rawValue)
        projectData = data
    }

    override func configCell(data: EQProjectModelProtocol, cell: UITableViewCell, indexPath: IndexPath) {
        guard let eqModel = data as? EQProjectModel,
            let saveCell = cell as? EQSaveProjectCell,
            let userVC = self.parent as? EQUserViewController else {
            return
        }
        saveCell.delegate = userVC
        saveCell.cellIndexPath = indexPath
        let buttonImage = eqModel.status == EQProjectStatus.temp ? UIImage(named: "wrench") : UIImage(named: "play")
        saveCell.projectTitleLabel.text = eqModel.name
        saveCell.cellIndicator.startAnimating()
        saveCell.trackCountLabel.text = String(eqModel.tracks.count)
        saveCell.playbutton.setBackgroundImage(buttonImage, for: .normal)
        let imageURLs = eqModel.tracks.map {
            $0.coverURL!
        }
        saveCell.cellEQChartView.alpha = 0
        saveCell.cellEQChartView.isUserInteractionEnabled = false

        saveCell.setDiscsImage(imageURLs: Array(imageURLs)) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let color = strongSelf.getProperColor(color: (saveCell.discImageLarge.image?.getPixelColor(saveCell.discImageLarge.center))!)
            saveCell.cellEQChartView.setChart(15, color: color, style: .cell)
            saveCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
            saveCell.cellIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                saveCell.cellEQChartView.alpha = 1
            })
        }
    }

    override func reloadTableView() {
        loadDataFromRealm()
        tableView.reloadData()
    }
}
