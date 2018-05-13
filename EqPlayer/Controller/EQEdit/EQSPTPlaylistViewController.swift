//
//  EQSPTPlaylistViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQSPTPlaylistViewController: UIViewController {
    var playlists = [SPTPartialPlaylist]()
    @IBOutlet var playlistTableView: UITableView!
    @IBAction func cancelAction(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTalbleView()
        fetchPlayList()
        // Do any additional setup after loading the view.
    }

    func setupTalbleView() {
        playlistTableView.delegate = self
        playlistTableView.dataSource = self
        playlistTableView.registeCell(cellIdentifier: EQPlaylistTableViewCell.typeName)
    }

    func fetchPlayList() {
        SPTPlaylistList.playlists(forUser: EQSpotifyManager.shard.auth?.session.canonicalUsername, withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
            //            self.activityIndicator.stopAnimating()
            if let listPage = response as? SPTPlaylistList, let playlists = listPage.items as? [SPTPartialPlaylist] {
                self.playlists = playlists // or however you want to parse these
                self.playlistTableView.reloadData()
                if listPage.hasNextPage {
                    self.getNextPlaylistPage(currentPage: listPage)
                }
            }
        })
    }

    func getNextPlaylistPage(currentPage: SPTListPage) {
        currentPage.requestNextPage(withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
            if let page = response as? SPTListPage, let playlists = page.items as? [SPTPartialPlaylist] {
                self.playlists.append(contentsOf: playlists) // or parse these beforehand, if you need/want to
                self.playlistTableView.reloadData()
                if page.hasNextPage {
                    self.getNextPlaylistPage(currentPage: page)
                }
            }
        })
    }
}

extension EQSPTPlaylistViewController: TableViewDelegateAndDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return playlists.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = playlistTableView.dequeueReusableCell(withIdentifier: EQPlaylistTableViewCell.typeName, for: indexPath) as? EQPlaylistTableViewCell else {
            return UITableViewCell()
        }
        cell.setupCell(listname: playlists[indexPath.row].name, numberOfTrack: Int(playlists[indexPath.row].trackCount))
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 75
    }
}