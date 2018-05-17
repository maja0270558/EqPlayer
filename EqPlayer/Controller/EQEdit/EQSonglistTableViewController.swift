//
//  EQSonglistTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import SwipeCellKit
import UIKit
class EQSonglistTableViewController: UITableViewController {
    var eqSettingManager: EQProjectModel?
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSPTTrackTableViewCell.typeName, for: indexPath) as?
            EQSPTTrackTableViewCell else {
                return UITableViewCell()
        }
        let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
        if let added = eqSettingManager?.tracks.contains(where: { $0.uri == track.uri}){
            if added {
                cell.checkedWidthConstraint.constant = 20
            } else {
                cell.checkedWidthConstraint.constant = 0
            }
        }
        cell.delegate = self
        cell.selectionStyle = .none
        cell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
        return cell
    }
    
    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
        return 100
    }
    override func scrollViewDidScroll(_: UIScrollView) {
        tableView.fadeTopCell()
    }
    func convertSPTTrackToEQTrack(sptTrack: SPTTrack) -> EQTrack {
        let eqTrack = EQTrack()
        if let previewURL = sptTrack.previewURL {
            eqTrack.previewURL = previewURL.absoluteString
        }
        if let imageURL = sptTrack.album.smallestCover {
            eqTrack.coverURL = imageURL.imageURL.absoluteString
        }
        guard let title = sptTrack.name, let artists = sptTrack.artists as? [SPTPartialArtist] else {
            return eqTrack
        }
        eqTrack.name = title
        var artistsString = ""
        for index in stride(from: 0, to: artists.count, by: 1) {
            if index == artists.count-1 {
                artistsString += artists[index].name
                //Last
            } else {
                artistsString += artists[index].name + ","
            }
        }
        eqTrack.artist = artistsString
        eqTrack.uri = sptTrack.uri.absoluteString
        return eqTrack
    }
}

extension EQSonglistTableViewController: SwipeTableViewCellDelegate {
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
        guard orientation == .right, let added = eqSettingManager?.tracks.contains(where: { $0.uri == track.uri}) else {
            return nil
        }
        let swipeAction = SwipeAction(style: .default, title: "") { _, indexPath in
            if added {
                //remove
                if let index = self.eqSettingManager?.tracks.index(where: {
                    $0.uri == track.uri
                }) {
                    self.eqSettingManager?.tracks.remove(at: index)
                }
            } else {
                //add
                self.eqSettingManager?.tracks.append(track)
            }
            EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
            self.tableView.reloadData()
        }
        if added {
            swipeAction.image = UIImage(named: "remove")
        } else {
            swipeAction.image = UIImage(named: "add")
        }
        swipeAction.backgroundColor = UIColor.clear
        return [swipeAction]
    }
    
    func tableView(_: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for _: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
        if let added = eqSettingManager?.tracks.contains(where: { $0.uri == track.uri}){
            if added {
                options.backgroundColor = UIColor(red: 1, green: 38 / 255, blue: 0, alpha: 0.3)
            } else {
                options.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 0, alpha: 0.3)
            }
        }
        options.expansionStyle = .selection
        options.transitionStyle = .reveal
        options.buttonVerticalAlignment = .center
        return options
    }
}
