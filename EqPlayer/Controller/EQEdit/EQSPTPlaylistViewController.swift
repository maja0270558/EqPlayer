//
//  EQSPTPlaylistViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQSPTPlaylistViewController: EQScrollableViewController {
    var playlists = [SPTPartialPlaylist]()
    var topItemSize: CGSize = CGSize.zero
    
    var playlistController: UIViewController {
        return data.mainController[0]
    }
    var songlistController: UIViewController {
        return data.mainController[1]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        visiableItemCount = 1
        // Do any additional setup after loading the view.
    }
    override func setupCell(cell _: UICollectionViewCell) {
    }

    func registerCollectionCell() {
        let iconNib = UINib(nibName: "IconCollectionViewCell", bundle: nil)
        topCollectionView.register(iconNib, forCellWithReuseIdentifier: "IconCollectionViewCell")
    }

    override func customizeTopItemWhenScrolling(_: CGFloat = 0) {
        // MARK fadein and fade out code
    }

    override func setupCollectionLayout() {
        if let iconLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let spaceCount = visiableItemCount - 1
            iconLayout.itemSize = topItemSize
            // Center the first icon
            var spacing = (UIScreen.main.bounds.width - iconLayout.itemSize.width * visiableItemCount)
            if spaceCount > 0 {
                spacing = 0
            } else {
                spacing /= spaceCount
            }
            iconLayout.minimumInteritemSpacing = 0
            iconLayout.minimumLineSpacing = spacing
            iconLayout.sectionInset = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: 0.0,
                right: 0.0
            )
            topPageWidth = UIScreen.main.bounds.width / spaceCount - topItemSize.width / 2
        }
    }
}

// extension EQSPTPlaylistViewController: TableViewDelegateAndDataSource {

//MARK for spotifylistController

//func fetchPlayList() {

//@IBAction func cancelAction(_: UIButton) {
//    dismiss(animated: true, completion: nil)
//}


//    SPTPlaylistList.playlists(forUser: EQSpotifyManager.shard.auth?.session.canonicalUsername, withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
//        //            self.activityIndicator.stopAnimating()
//        if let listPage = response as? SPTPlaylistList, let playlists = listPage.items as? [SPTPartialPlaylist] {
//            self.playlists = playlists // or however you want to parse these
//            self.playlistTableView.reloadData()
//            if listPage.hasNextPage {
//                self.getNextPlaylistPage(currentPage: listPage)
//            }
//        }
//    })
//}
//
//func getNextPlaylistPage(currentPage: SPTListPage) {
//    currentPage.requestNextPage(withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
//        if let page = response as? SPTListPage, let playlists = page.items as? [SPTPartialPlaylist] {
//            self.playlists.append(contentsOf: playlists) // or parse these beforehand, if you need/want to
//            self.playlistTableView.reloadData()
//            if page.hasNextPage {
//                self.getNextPlaylistPage(currentPage: page)
//            }
//        }
//    })
//}

//    func numberOfSections(in _: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
//        return playlists.count
//    }
//
//    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = playlistTableView.dequeueReusableCell(withIdentifier: EQPlaylistTableViewCell.typeName, for: indexPath) as? EQPlaylistTableViewCell else {
//            return UITableViewCell()
//        }
//        cell.setupCell(listname: playlists[indexPath.row].name, numberOfTrack: Int(playlists[indexPath.row].trackCount))
//        return cell
//    }
//
//    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
//        return 75
//    }
// }
