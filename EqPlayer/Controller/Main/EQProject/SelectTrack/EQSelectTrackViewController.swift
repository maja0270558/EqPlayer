//
//  EQSelectTrackViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import SwipeCellKit

class EQSelectTrackViewController: EQScrollableViewController {
    lazy var topItemSize: CGSize! = CGSize(width: UIScreen.main.bounds.width, height: topCollectionView.bounds.height)
    var titleLabels = ["播放列表", "歌單"]
    var eqSettingManager: EQSettingModelManager?
    var playlistController: EQPlaylistTableViewController? {
        return data.mainController[0] as? EQPlaylistTableViewController
    }

    var songlistController: EQSonglistTableViewController? {
        return data.mainController[1] as? EQSonglistTableViewController
    }
    override func onDismiss() {
      dismiss(animated: true) {
        
      }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setCanPanToDismiss(true)
        registerCollectionCell()
        setupControllersAndCells()
        controllerInit()
        // Do any additional setup after loading the view.
    }

    override func setupCell(cell: UICollectionViewCell, atIndex: Int) {
        if let topCell = cell as? EQSelectTrackTopCollectionViewCell {
            topCell.resetCell()
            switch atIndex {
            case 0:
                topCell.backButton.isHidden = true
            default:
                break
            }
            topCell.delegate = self
            topCell.titleLabel.text = titleLabels[atIndex]
        }
    }

    func setupControllersAndCells() {
        visiableItemCount = 1
        data = ScrollableControllerDataModel(
            topCellId: ["EQSelectTrackTopCollectionViewCell", "EQSelectTrackTopCollectionViewCell"],
            mainController: [EQPlaylistTableViewController(), EQSonglistTableViewController()]
        )
        topCollectionView.allowsSelection = false
        topCollectionView.isScrollEnabled = false
        mainScrollView.isScrollEnabled = false
        playlistController?.delegate = self
        if let manager = self.eqSettingManager {
            songlistController?.eqSettingManager = manager
        }
    }

    func registerCollectionCell() {
        let iconNib = UINib(nibName: "EQSelectTrackTopCollectionViewCell", bundle: nil)
        topCollectionView.register(iconNib, forCellWithReuseIdentifier: "EQSelectTrackTopCollectionViewCell")
    }

    override func customizeTopItemWhenScrolling(_: CGFloat = 0) {
        let cells = topCollectionView.visibleCells
        for cell in cells {
            if let iconCell = cell as? EQSelectTrackTopCollectionViewCell {
                let row = CGFloat((topCollectionView.indexPath(for: iconCell)?.row)!)
                iconCell.setupAlpha(currentIndex: currentIndex, cellRow: row)
            }
        }
    }

    override func setupCollectionLayout() {
        if let iconLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            iconLayout.itemSize = topItemSize
            topPageWidth = UIScreen.main.bounds.width
        }
    }
}

extension EQSelectTrackViewController: EQSelectTrackTopCollectionViewCellProtocol {
    func didClickCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    func didClickBackButton() {
        EQSpotifyManager.shard.resetPreviewURL()
        goTo(pageAt: 0)
    }
}

extension EQSelectTrackViewController: EQPlaylistTableViewControllerDelegate {
    func didSelect(playlist: SPTPartialPlaylist) {
        titleLabels[1] = playlist.name
        topCollectionView.reloadData()
        songlistController?.songlists.removeAll()
        songlistController?.tableView.reloadData()
        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: EQSpotifyManager.shard.auth?.session.accessToken) { error, snapshot in
            if error != nil {
                return
            }

            if let snap = snapshot as? SPTPlaylistSnapshot, let trackListPage = snap.firstTrackPage.items as? [SPTPlaylistTrack] {
                self.songlistController?.songlists = trackListPage
                self.songlistController?.tableView.reloadData()
                if snap.firstTrackPage.hasNextPage {
                    self.getNextPageTrack(currentPage: snap.firstTrackPage)
                }
            }
        }
        goTo(pageAt: 1)
    }

    func getNextPageTrack(currentPage: SPTListPage) {
        currentPage.requestNextPage(withAccessToken: EQSpotifyManager.shard.auth?.session.accessToken, callback: { _, response in
            if let page = response as? SPTListPage, let trackList = page.items as? [SPTPlaylistTrack] {
                self.songlistController?.songlists.append(contentsOf: trackList)
                self.songlistController?.tableView.reloadData()
                if page.hasNextPage {
                    self.getNextPageTrack(currentPage: page)
                }
            }
        })
    }
}


