//
//  EQDiscoverViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/31.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQDiscoverViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    var discoverPostData = [EQPostCellModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        loadPostData()
        subscribeNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotification()
    }

    func setupTableView() {
        tableView.registeCell(cellIdentifier: EQDiscoverTableViewCell.typeName)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }

    func subscribeNotification() {
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didSaveEQProject), notification: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didSaveEQProject), notification: Notification.Name.eqProjectDelete)
    }

    func removeNotification() {
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectDelete)
    }

    @objc func didSaveEQProject() {
        loadPostData()
    }

    func loadPostData() {
        EQFirebaseManager.getPost(withPath: "post") { [weak self] cellModelArray in
            let discoverModelDatas = cellModelArray.filter({ (model) -> Bool in
                model.postUserUID != EQUserManager.shard.userUID
            })
            self?.discoverPostData = discoverModelDatas
            self?.tableView.reloadData()
            discoverModelDatas.forEach({ model in
                EQFirebaseManager.getUser(withUID: model.postUserUID, failedHandler: {
                }, completion: { userModel in
                    model.postUserPhotoURL = (userModel.photoURL?.absoluteString)!
                    self?.discoverPostData = discoverModelDatas
                    self?.tableView.reloadData()
                })
            })
        }
    }
}

extension EQDiscoverViewController: TableViewDelegateAndDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return discoverPostData.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQDiscoverTableViewCell.typeName, for: indexPath) as?
            EQDiscoverTableViewCell else {
            return UITableViewCell()
        }
        let cellModel = discoverPostData[indexPath.row]
        let eqModel = cellModel.projectModel

        cell.userPhoto.sd_setImage(with: URL(string: cellModel.postUserPhotoURL), placeholderImage: #imageLiteral(resourceName: "user"), options: [], completed: nil)
        cell.userNameLabel.text = cellModel.postUserName
        cell.postTimeLabel.text = EQDateFormatter().dateWithUnitTime(time: cellModel.postTime)

        cell.descriptionLabel.text = eqModel.detailDescription
        cell.delegate = self
        cell.cellIndexPath = indexPath
        cell.projectTitleLabel.text = eqModel.name
        cell.cellIndicator.startAnimating()
        cell.trackCountLabel.text = String(eqModel.tracks.count)
        let imageURLs = eqModel.tracks.map {
            $0.coverURL!
        }
        cell.cellEQChartView.alpha = 0
        cell.cellEQChartView.isUserInteractionEnabled = false
        cell.selectionStyle = .none
        cell.setDiscsImage(imageURLs: Array(imageURLs)) {
            let color = self.getProperColor(color: (cell.discImageLarge.image?.getPixelColor(cell.discImageLarge.center))!)
            cell.cellEQChartView.setChart(15, color: color, style: .cell)
            cell.cellEQChartView.setEntryValue(yValues: Array(eqModel.eqSetting))
            cell.cellIndicator.stopAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                cell.cellEQChartView.alpha = 1
            })
        }
        return cell
    }

    func getProperColor(color: UIColor) -> UIColor {
        if color.isLightColor() {
            return color
        }
        return color.lighter(by: 60)!
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 100
    }
}

extension EQDiscoverViewController: EQDiscoverTableViewCellDelegate {
    func didClickMoreOptionButton(indexPath _: IndexPath) {
        moreOptionAlert()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let mainController = self.parent as? EQMainScrollableViewController else {
            return
        }

        mainController.openPlayerAndPlayback(data: discoverPostData[indexPath.row].projectModel)
    }
}

extension EQDiscoverViewController {
    func scrollViewDidScroll(_: UIScrollView) {
        tableView.fadeTopCell()
    }
}
