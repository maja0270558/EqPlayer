//
//  EQTrackTableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/8.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import SwipeCellKit

protocol EQTrackTableViewControllerDelegate: class {
    func didScrollTableView(scrollView: UIScrollView, offset: CGFloat)
}

class EQTrackTableViewController: EQPannableViewController {
    var tableViewData: [EQTrackProtocol]?
    var eqSettingManager: EQSettingModelManager = EQSettingModelManager()
    var tableView: UITableView?
    var isParentTrackViewController: Bool = true
    weak var delegate: EQTrackTableViewControllerDelegate?

    fileprivate var identifier = "EQSonglistTableViewCell"

    func configCell(data _: EQTrackProtocol, cell _: UITableViewCell, indexPath _: IndexPath) {
        return
    }

    func reloadTrack() {
        tableView?.reloadData()
        tableView?.fadeTopCell()
    }
}

extension EQTrackTableViewController: TableViewDelegateAndDataSource {
    func setupTableView(typeName: String, tableView: UITableView) {
        identifier = typeName
        self.tableView = tableView
        self.tableView?.registeCell(cellIdentifier: identifier)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.backgroundColor = UIColor.clear
        self.tableView?.separatorStyle = .none
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let data = tableViewData else {
            return 0
        }
        return data.count
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt indexPath: IndexPath) {
        resetCell(indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSonglistTableViewCell.typeName, for: indexPath) as?
            EQSonglistTableViewCell,
            let data = tableViewData else {
            return UITableViewCell()
        }

        let track = data[indexPath.row].getTrack()
        let added = eqSettingManager.tempModel.tracks.contains(where: { $0.uri == track.uri })
        cell.checkedWidthConstraint.constant = 0
        if !isParentTrackViewController {
            if added {
                if added {
                    cell.checkedWidthConstraint.constant = 20
                } else {
                    cell.checkedWidthConstraint.constant = 0
                }
            }
        }

        cell.delegate = self
        cell.cellDelegate = self
        cell.indexPath = indexPath
        cell.track = track
        cell.selectionStyle = .none
        cell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
        resetCell(indexPath: indexPath)
        if EQSpotifyManager.shard.previousPreviewURLString == cell.track?.uri && EQSpotifyManager.shard.currentPlayingType == .preview {
            cell.obsevePreviewDuration()
            cell.previewButton.isSelected = true
            cell.startObseve()
        }
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_: UITableView, estimatedHeightForHeaderInSection _: Int) -> CGFloat {
        return 54
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.didScrollTableView(scrollView: scrollView, offset: scrollView.contentOffset.y)
        guard let tableView = scrollView as? UITableView else {
            return
        }
        tableView.fadeTopCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let data = tableViewData else {
            return
        }

        if isParentTrackViewController {
            return
        }

        let track = data[indexPath.row].getTrack()
        let added = eqSettingManager.tempModel.tracks.contains(where: { $0.uri == track.uri })
        if added {
            if let index = self.eqSettingManager.tempModel.tracks.index(where: {
                $0.uri == track.uri
            }) {
                eqSettingManager.tempModel.tracks.remove(at: index)
            }
        } else {
            eqSettingManager.tempModel.tracks.append(track)
        }
        eqSettingManager.isModify = true
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
        tableView.reloadDataUpdateFade()
    }
}

extension EQTrackTableViewController: SwipeTableViewCellDelegate {
    func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard let data = tableViewData else {
            return nil
        }
        let track = data[indexPath.row].getTrack()
        guard orientation == .right else {
            return nil
        }
        let added = eqSettingManager.tempModel.tracks.contains(where: { $0.uri == track.uri })
        let swipeAction = SwipeAction(style: .default, title: "") { _, _ in

            if added {
                if let index = self.eqSettingManager.tempModel.tracks.index(where: {
                    $0.uri == track.uri
                }) {
                    self.eqSettingManager.tempModel.tracks.remove(at: index)
                }
            } else {
                self.eqSettingManager.tempModel.tracks.append(track)
            }
            self.eqSettingManager.isModify = true
            EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
            self.reloadTrack()
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
        guard let data = tableViewData else {
            return options
        }
        let track = data[indexPath.row].getTrack()
        let added = eqSettingManager.tempModel.tracks.contains(where: { $0.uri == track.uri })
        if added {
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

extension EQTrackTableViewController: EQSonglistTableViewCellDelegate {
    func didPreviewButtonClick(indexPath: IndexPath) {
        guard let cell = tableView?.cellForRow(at: indexPath) as? EQSonglistTableViewCell,
            let data = tableViewData else {
            return
        }
        let track = data[indexPath.row].getTrack()
        if cell.previewButton.isSelected {
            // 試聽的那個
            resetAllVisibleCell()
            EQSpotifyManager.shard.previousPreviewURLString = track.uri
            EQSpotifyManager.shard.playPreview(uri: track.uri, duration: track.duration) {
                EQSpotifyManager.shard.durationObseve.previewCurrentDuration = 0
                cell.startObseve()
                cell.previewButton.isSelected = true
                if !self.isParentTrackViewController {
                    EQNotifycationCenterManager.post(name: Notification.Name.eqProjectPlayPreviewTrack)
                }
            }

        } else {
            // 按自己
            EQSpotifyManager.shard.player?.setIsPlaying(false, callback: { error in
                if error != nil {
                    return
                }
                EQSpotifyManager.shard.currentPlayingType = .project
                self.resetAllVisibleCell()
            })
        }
    }

    func resetCell(indexPath: IndexPath?) {
        guard let resetIndexPath = indexPath,
            let cell = tableView?.cellForRow(at: resetIndexPath) as? EQSonglistTableViewCell else {
            return
        }

        cell.timer?.invalidate()
        cell.previewProgressBar.progress = 0
        cell.previewButton.isSelected = false
    }

    func resetAllVisibleCell() {
        guard let cells = tableView?.visibleCells as? [EQSonglistTableViewCell] else {
            return
        }
        cells.forEach { cell in
            cell.timer?.invalidate()
            cell.previewProgressBar.progress = 0
            cell.previewButton.isSelected = false
        }
    }
}
