//
//  EQSearchViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import SwipeCellKit
import UIKit

protocol EQSearchViewControllerDelegate: class {
    func didDismiss()
}

class EQSearchViewController: EQTrackTableViewController {
    weak var searchViewControllerdelegate: EQSearchViewControllerDelegate?
    @IBOutlet var searchBar: EQCustomSearchBar!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var searchTrackTableView: UITableView!

    @IBAction func cancelAction(_: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.searchViewControllerdelegate?.didDismiss()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(typeName: EQSonglistTableViewCell.typeName, tableView: searchTrackTableView)
        isParentTrackViewController = false
        setupSearchBar()
    }

    func setupSearchBar() {
        let searchBarBackground = UIImage.roundedImage(image: UIImage.imageWithColor(color: UIColor.clear, size: CGSize(width: 28, height: 28)), cornerRadius: 2)
        searchBar.setSearchFieldBackgroundImage(searchBarBackground, for: .normal)
        cancelButton.alpha = 0
        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.cancelButton.alpha = 1
        }
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
    }
}

extension EQSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text?.isEmpty)! {
            dismiss(animated: true) { [weak self] in
                self?.searchViewControllerdelegate?.didDismiss()
            }
        }
        searchBar.resignFirstResponder()
    }

    func searchBar(_: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            if tableViewData != nil {
                tableViewData!.removeAll()
            }
            searchTrackTableView.reloadDataUpdateFade()
        }
        fetchTrack(query: searchText)
    }

    func fetchTrack(query: String) {
        SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: EQSpotifyManager.shard.auth?.session.accessToken) { [weak self] _, listPage in
            guard let listPage = listPage as? SPTListPage,
                let tracks = listPage.items as? [SPTPartialTrack] else {
                return
            }
            self?.tableViewData = tracks
            self?.searchTrackTableView.reloadDataUpdateFade()
        }
    }
}
