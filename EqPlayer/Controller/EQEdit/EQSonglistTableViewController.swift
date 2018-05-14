//
//  EQSonglistTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import SwipeCellKit
protocol EQSonglistTableViewControllerDelegate: class {
    func didSelect(playlist: SPTTrack)
}

class EQSonglistTableViewController: UITableViewController {
    weak var delegate: EQSonglistTableViewControllerDelegate?
    var songlists = [SPTTrack]()
    var addedList = [SPTTrack]()
    override func viewDidLoad() {
        setupTableView()
    }

    func setupTableView() {
        tableView.registeCell(cellIdentifier: EQSPTTrackTableViewCell.typeName)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
    }

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return songlists.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let added = addedList.contains(where: {$0.identifier == songlists[indexPath.row].identifier})
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSPTTrackTableViewCell.typeName, for: indexPath) as? EQSPTTrackTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        let title = songlists[indexPath.row].name
        let artists = songlists[indexPath.row].artists as? [SPTPartialArtist]
        guard let imageURL = songlists[indexPath.row].album.smallestCover else {
            cell.setupCell(albumPic: nil, title: title, artist: artists)
            return cell
        }
        if added {
            cell.checkedWidthConstraint.constant = 25
        } else {
            cell.checkedWidthConstraint.constant = 0
        }
        cell.setupCell(albumPic: imageURL.imageURL, title: title, artist: artists)
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
//        delegate?.didSelect(playlist: songlists[indexPath.row])
    }
}
extension EQSonglistTableViewController: SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let added = addedList.contains(where: {$0.identifier == songlists[indexPath.row].identifier})
        let swipeAction = SwipeAction(style: .default, title: "") { action, indexPath in
            if added {
                if let index =   self.addedList.index(where: {
                    $0.identifier == self.songlists[indexPath.row].identifier
                }) {
                    self.addedList.remove(at: index)
                    self.tableView.reloadData()
                }
            } else {
                self.addedList.append(self.songlists[indexPath.row])
                self.tableView.reloadData()
            }
        }
        if added {
            swipeAction.image = UIImage(named: "remove")
        } else {
            swipeAction.image = UIImage(named: "add")
        }
        swipeAction.backgroundColor = UIColor.clear
        return [swipeAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        let added = addedList.contains(where: {$0.identifier == songlists[indexPath.row].identifier})
        if added {
            options.backgroundColor = UIColor(red: 1, green: 38/255, blue: 0, alpha: 0.3)
        } else {
            options.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 0, alpha: 0.3)
        }
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        options.buttonVerticalAlignment = .center
        return options
    }
}
