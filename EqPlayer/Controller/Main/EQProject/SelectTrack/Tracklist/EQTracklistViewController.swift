//
//  EQTracklistViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQTracklistViewController: EQTrackTableViewController {
    @IBOutlet var trackTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(typeName: EQSonglistTableViewCell.typeName, tableView: trackTableView)
        isParentTrackViewController = false
    }
}
