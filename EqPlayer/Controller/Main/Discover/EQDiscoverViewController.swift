//
//  EQDiscoverViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/31.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQDiscoverViewController: EQProjectTableViewController {
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupReuseCellType(typeName: EQDiscoverTableViewCell.typeName, tableView: tableView)
        setupTableView()
        loadDataFromFirebase()
    }

    func loadDataFromFirebase() {
        EQFirebaseManager.getPost(withPath: "post") { [weak self] cellModelArray in
            let discoverModelDatas = cellModelArray.filter({ (model) -> Bool in
                model.postUserUID != EQUserManager.shard.userUID
            })
            self?.projectData = discoverModelDatas
            self?.tableView.reloadData()
            discoverModelDatas.forEach({ model in
                EQFirebaseManager.getUser(withUID: model.postUserUID,
                                          failedHandler: {},
                                          completion: { userModel in
                                              model.postUserPhotoURL = (userModel.photoURL?.absoluteString)!
                                              self?.projectData = discoverModelDatas
                                              self?.tableView.reloadData()
                })
            })
        }
    }

    override func reloadTableView() {
        loadDataFromFirebase()
    }

    override func configCell(data: EQProjectModelProtocol, cell: UITableViewCell, indexPath: IndexPath) {
        guard let cellModel = data as? EQPostCellModel,
            let discoverCell = cell as? EQDiscoverTableViewCell else {
            return
        }
        let eqModel = cellModel.projectModel
        discoverCell.delegate = self
        discoverCell.userPhoto.sd_setImage(with: URL(string: cellModel.postUserPhotoURL), placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        discoverCell.userNameLabel.text = cellModel.postUserName
        discoverCell.postTimeLabel.text = EQDateFormatter().dateWithUnitTime(time: cellModel.postTime)

        discoverCell.descriptionLabel.text = eqModel.detailDescription
        discoverCell.cellIndexPath = indexPath
        discoverCell.projectTitleLabel.text = eqModel.name
        discoverCell.cellIndicator.startAnimating()
        discoverCell.trackCountLabel.text = String(eqModel.tracks.count)
        let imageURLs = eqModel.tracks.map {
            $0.coverURL!
        }
        discoverCell.cellEQChartView.alpha = 0
        discoverCell.cellEQChartView.isUserInteractionEnabled = false
        discoverCell.selectionStyle = .none
        discoverCell.setDiscsImage(imageURLs: Array(imageURLs)) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let color = strongSelf.getProperColor(color: (discoverCell.discImageLarge.image?.getPixelColor(discoverCell.discImageLarge.center))!)
            discoverCell.cellEQChartView.setChart(15, color: color, style: .cell)
            discoverCell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
            discoverCell.cellIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                discoverCell.cellEQChartView.alpha = 1
            })
        }
    }

    func setupTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
}

extension EQDiscoverViewController: EQSaveProjectCellDelegate {
    func didClickMoreOptionButton(indexPath _: IndexPath) {
        moreOptionAlert()
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = projectData as? [EQPostCellModel],
            let mainController = parent as? EQMainScrollableViewController else {
            return
        }
        let dataCopy = EQProjectModel(value: data[indexPath.row].projectModel)
        mainController.openPlayerAndPlayback(data: dataCopy)

    }
}
