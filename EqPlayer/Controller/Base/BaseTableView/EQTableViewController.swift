//
//  EQTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

protocol EQTableViewSession: class {
    var headerIdentifier: String? { get }
    var headerView: UIView? { get }
    var headerHeight: CGFloat { get set }
    var headerOperator: (Any, UIView) -> Void { get }
    var headerData: Any? { get set }
    var cellIdentifier: String? { get }
    var cell: UITableViewCell? { get }
    var cellHeight: CGFloat { get }
    var cellOperator: (Any, UITableViewCell, IndexPath) -> Void { get }
    var cellDatas: [Any] { get set }
}

class EQTableViewController: EQPannableViewController, UITableViewDelegate, UITableViewDataSource {
    var sectionProviders: [EQTableViewSession] = []
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func getHeaderData<T>(_ index: Int) -> [T]? {
        return sessionOf(index).headerData as? [T]
    }

    func getCellData<T>(_ index: Int) -> [T]? {
        return sessionOf(index).cellDatas as? [T]
    }

    func sessionOf(_ index: Int) -> EQTableViewSession {
        return sectionProviders[index]
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionProviders[section].cellDatas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let keeper = sectionProviders[indexPath.section]

        guard let identifier = keeper.cellIdentifier else {
            guard let cell = keeper.cell else {
                let cell = UITableViewCell()
                cell.backgroundColor = UIColor.clear
                keeper.cellOperator(keeper.cellDatas[indexPath.row], cell, indexPath)
                return cell
            }

            keeper.cellOperator(keeper.cellDatas[indexPath.row], cell, indexPath)
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        keeper.cellOperator(keeper.cellDatas[indexPath.row], cell, indexPath)
        return cell
    }

//    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
//        return 214
//    }
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionProviders[indexPath.section].cellHeight
    }

    func numberOfSections(in _: UITableView) -> Int {
        return sectionProviders.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let keeper = sectionProviders[section]
        guard let identifier = keeper.headerIdentifier else {
            guard let view = keeper.headerView else {
                return UIView()
            }

            guard let data = keeper.headerData else {
                keeper.headerOperator("", view)
                return view
            }

            keeper.headerOperator(data, view)
            return view
        }

        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: identifier),
            let data = keeper.headerData
        else {
            return UIView()
        }

        keeper.headerOperator(data, view)
        return view
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionProviders[section].headerHeight
    }

    func tableView(_: UITableView, estimatedHeightForHeaderInSection _: Int) -> CGFloat {
        return 54
    }
}
