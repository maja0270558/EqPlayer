//
//  EQPlaylistTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol EQPlaylistTableViewControllerDelegate: class {
    func didSelect(playlist: SPTPartialPlaylist)
}

class EQPlaylistTableViewController: UITableViewController {
    weak var delegate: EQPlaylistTableViewControllerDelegate?
    var playlists = [SPTPartialPlaylist]()

    override func viewDidLoad() {
        setupTableView()
        fetchPlayList()
    }

    func setupTableView() {
        tableView.registeCell(cellIdentifier: EQPlaylistTableViewCell.typeName)
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
    }

    func fetchPlayList() {
      
        guard let session = EQSpotifyManager.shard.auth?.session else {
          return
        }
      
        SPTPlaylistList.playlists(forUser: session.canonicalUsername, withAccessToken: session.accessToken, callback: { _, response in
            if let listPage = response as? SPTPlaylistList, let playlists = listPage.items as? [SPTPartialPlaylist] {
                self.playlists = playlists // or however you want to parse these
                self.tableView.reloadDataUpdateFade()
                if listPage.hasNextPage {
                    self.getNextPlaylistPage(currentPage: listPage)
                }
            }
        })
    }

    func getNextPlaylistPage(currentPage: SPTListPage) {
        currentPage.requestNextPage(withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
            if let page = response as? SPTListPage, let playlists = page.items as? [SPTPartialPlaylist] {
                self.playlists.append(contentsOf: playlists)
                self.tableView.reloadDataUpdateFade()
                if page.hasNextPage {
                    self.getNextPlaylistPage(currentPage: page)
                }
            }
        })
    }
}

extension EQPlaylistTableViewController {
    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return playlists.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQPlaylistTableViewCell.typeName, for: indexPath) as? EQPlaylistTableViewCell else {
            return UITableViewCell()
        }

        cell.setupCell(listname: playlists[indexPath.row].name, numberOfTrack: Int(playlists[indexPath.row].trackCount))
        cell.selectionStyle = .none
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 75
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(playlist: playlists[indexPath.row])
    }
}

extension EQPlaylistTableViewController {
    override func scrollViewDidScroll(_: UIScrollView) {
        tableView.fadeTopCell()
    }
}
