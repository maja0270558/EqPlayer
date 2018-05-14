//
//  EQSonglistTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol EQSonglistTableViewControllerDelegate: class {
    func didSelect(playlist: SPTTrack)
}

class EQSonglistTableViewController: UITableViewController {
    weak var delegate: EQSonglistTableViewControllerDelegate?
    var songlists = [SPTTrack]()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSPTTrackTableViewCell.typeName, for: indexPath) as? EQSPTTrackTableViewCell else {
            return UITableViewCell()
        }
        let title = songlists[indexPath.row].name
        let artists = songlists[indexPath.row].artists as? [SPTPartialArtist]
        guard let imageURL = songlists[indexPath.row].album.smallestCover else {
            cell.setupCell(albumPic: nil, title: title, artist: artists)
            return cell
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
