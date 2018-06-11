//
//  EQProjectTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/6.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
protocol EQProjectTableViewControllerDelegate: class {
    func didScrollTableView(scrollView: UIScrollView, offset: CGFloat)
    func didSelectProjectCell(at: IndexPath, data: EQProjectModelProtocol)
}

class EQProjectTableViewController: UIViewController {
    var projectData: [EQProjectModelProtocol]?
    weak var delegate: EQProjectTableViewControllerDelegate?
    fileprivate var identifier = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeNotification()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeNotification()
    }

    func subscribeNotification() {
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didModifyData), notification: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.addObserver(observer: self, selector: #selector(didModifyData), notification: Notification.Name.eqProjectDelete)
    }

    @objc func didModifyData() {
        reloadTableView()
    }

    func removeNotification() {
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectSave)
        EQNotifycationCenterManager.removeObseve(observer: self, name: Notification.Name.eqProjectDelete)
    }

    func configCell(data _: EQProjectModelProtocol, cell _: UITableViewCell, indexPath _: IndexPath) {
        return
    }

    func reloadTableView() {
        return
    }
}

extension EQProjectTableViewController: TableViewDelegateAndDataSource {
    func setupReuseCellType(typeName: String, tableView: UITableView) {
        identifier = typeName
        tableView.registeCell(cellIdentifier: identifier)
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let data = projectData else {
            return 0
        }
        return data.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = projectData else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.selectionStyle = UITableViewCellSelectionStyle.none

        configCell(data: data[indexPath.row], cell: cell, indexPath: indexPath)
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForHeaderInSection _: Int) -> CGFloat {
        return 54
    }

    func getProperColor(color: UIColor) -> UIColor {
        if color.isLightColor() {
            return color
        }
        return color.lighter(by: 60)!
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollTableView(scrollView: scrollView, offset: scrollView.contentOffset.y)
        guard let tableView = scrollView as? UITableView else {
            return
        }
        tableView.fadeTopCell()
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = projectData else {
            return
        }
        delegate?.didSelectProjectCell(at: indexPath, data: data[indexPath.row])
    }
}
