//
//  EQSelectTrackViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import SwipeCellKit
import UIKit

class EQSelectTrackViewController: EQScrollableViewController {
    @IBOutlet var searchBar: EQCustomSearchBar!
    lazy var topItemSize: CGSize! = CGSize(width: UIScreen.main.bounds.width, height: topCollectionView.bounds.height)
    var titleLabels = ["播放列表", "歌單"]
    var eqSettingManager: EQSettingModelManager?
    var playlistController: EQPlaylistTableViewController? {
        return data.mainController[0] as? EQPlaylistTableViewController
    }

    var tracklistController: EQTracklistViewController? {
        return data.mainController[1] as? EQTracklistViewController
    }

    override func onDismiss() {
        dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setCanPanToDismiss(true)
        setupSearchBar()
        registerCollectionCell()
        setupControllersAndCells()
        subControllerInit()
        setupSubController()
        // Do any additional setup after loading the view.
    }

    func setupSearchBar() {
        searchBar.delegate = self
    }

    func setupSubController() {
        playlistController?.delegate = self
        if let manager = self.eqSettingManager {
            tracklistController?.eqSettingManager = manager
        }
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
        let trackController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: "EQTracklistViewController")
        controllers = [EQPlaylistTableViewController(), trackController]
        cells = ["EQSelectTrackTopCollectionViewCell", "EQSelectTrackTopCollectionViewCell"]
        topCollectionView.allowsSelection = false
        topCollectionView.isScrollEnabled = false
        mainScrollView.isScrollEnabled = false
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
        goTo(pageAt: 0)
    }
}

extension EQSelectTrackViewController: EQPlaylistTableViewControllerDelegate {
    func didSelect(playlist: SPTPartialPlaylist) {
        titleLabels[1] = playlist.name
        topCollectionView.reloadData()
        tracklistController?.tableViewData?.removeAll()
        tracklistController?.trackTableView.reloadData()

        SPTPlaylistSnapshot.playlist(withURI: playlist.uri, accessToken: EQSpotifyManager.shard.auth?.session.accessToken) { error, snapshot in
            if error != nil {
                return
            }

            if let snap = snapshot as? SPTPlaylistSnapshot, let trackListPage = snap.firstTrackPage.items as? [SPTPlaylistTrack] {
                self.tracklistController?.tableViewData = trackListPage
                self.tracklistController?.trackTableView.reloadDataUpdateFade()

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
                self.tracklistController?.tableViewData!.append(contentsOf: trackList)
                self.tracklistController?.trackTableView.reloadDataUpdateFade()

                if page.hasNextPage {
                    self.getNextPageTrack(currentPage: page)
                }
            }
        })
    }
}

extension EQSelectTrackViewController: UISearchBarDelegate, EQSearchViewControllerDelegate {
    func didDismiss() {
        tracklistController?.trackTableView.reloadDataUpdateFade()
        UIView.animate(withDuration: 0.25, animations: {
            self.identityAnimation()
        }, completion: { _ in
            self.resignFirstResponder()
        })
    }

    func moveUpAnimation() {
        searchBar.transform = CGAffineTransform(translationX: 0, y: -topCollectionView.bounds.height)
        topCollectionView.transform = CGAffineTransform(translationX: 0, y: -topCollectionView.bounds.height * 2)
    }

    func identityAnimation() {
        searchBar.transform = CGAffineTransform.identity
        topCollectionView.transform = CGAffineTransform.identity
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)

        UIView.animate(withDuration: 0.25, animations: {
            self.moveUpAnimation()
        }, completion: { _ in
            if let searchViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQSearchViewController.self)) as? EQSearchViewController {
                searchViewController.modalPresentationStyle = .overCurrentContext
                searchViewController.modalTransitionStyle = .crossDissolve
                searchViewController.searchViewControllerdelegate = self
                searchViewController.eqSettingManager = (self.eqSettingManager)!
                self.present(searchViewController, animated: true, completion: nil)
            }
        })
    }
}
