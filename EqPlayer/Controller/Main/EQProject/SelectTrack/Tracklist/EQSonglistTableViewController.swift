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
  var eqSettingManager: EQSettingModelManager?
  var songlists = [SPTTrack]()
  var previousPreviewIndex: IndexPath?
  var previousPreviewURLString: String = ""
  
  override func viewDidLoad() {
    setupTableView()
  }
  
  func setupTableView() {
    tableView.registeCell(cellIdentifier: EQSonglistTableViewCell.typeName)
    tableView.backgroundColor = UIColor.clear
    tableView.separatorStyle = .none
  }
}

extension EQSonglistTableViewController {
  
  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return songlists.count
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    resetCell(indexPath: indexPath)
  }
  
  override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSonglistTableViewCell.typeName, for: indexPath) as?
      EQSonglistTableViewCell else {
        return UITableViewCell()
    }
    
    let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
    
    if let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) {
      if added {
        cell.checkedWidthConstraint.constant = 20
      } else {
        cell.checkedWidthConstraint.constant = 0
      }
    }
    
    cell.indexPath = indexPath
    cell.track = track
    cell.delegate = self
    cell.cellDelegate = self
    cell.selectionStyle = .none
    cell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
    if previousPreviewURLString == cell.track?.uri {
      cell.obsevePreviewDuration()
      cell.previewButton.isSelected = true
      cell.startObseve()
    }
    return cell
  }
  
  override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
    return UITableViewAutomaticDimension
  }
  
  override func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
    return 100
  }
}

extension EQSonglistTableViewController {
  override func scrollViewDidScroll(_: UIScrollView) {
    tableView.fadeTopCell()
  }
}

extension EQSonglistTableViewController: SwipeTableViewCellDelegate {
  func convertSPTTrackToEQTrack(sptTrack: SPTTrack) -> EQTrack {
    let eqTrack = EQTrack()
    
    if let previewURL = sptTrack.previewURL {
      eqTrack.previewURL = previewURL.absoluteString
    }
    
    if let imageURL = sptTrack.album.largestCover {
      eqTrack.coverURL = imageURL.imageURL.absoluteString
    }
    
    guard let title = sptTrack.name, let artists = sptTrack.artists as? [SPTPartialArtist] else {
      return eqTrack
    }
    
    eqTrack.name = title
    var artistsString = ""
    
    for index in stride(from: 0, to: artists.count, by: 1) {
      if index == artists.count - 1 {
        artistsString += artists[index].name
      } else {
        artistsString += artists[index].name + ","
      }
    }
    
    eqTrack.artist = artistsString
    eqTrack.uri = sptTrack.uri.absoluteString
    eqTrack.duration = sptTrack.duration
    return eqTrack
  }
  
  func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
    
    guard orientation == .right, let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) else {
      return nil
    }
    
    let swipeAction = SwipeAction(style: .default, title: "") { _, _ in
      
      if added {
        if let index = self.eqSettingManager?.tempModel.tracks.index(where: {
          $0.uri == track.uri
        }) {
          self.eqSettingManager?.tempModel.tracks.remove(at: index)
        }
      } else {
        self.eqSettingManager?.tempModel.tracks.append(track)
      }
      
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
      self.tableView.reloadDataUpdateFade()
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
    
    if let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) {
      if added {
        options.backgroundColor = UIColor(red: 1, green: 38 / 255, blue: 0, alpha: 0.3)
      } else {
        options.backgroundColor = UIColor(red: 0.3, green: 0.5, blue: 0, alpha: 0.3)
      }
    }
    eqSettingManager?.isModify = true
    options.expansionStyle = .selection
    options.transitionStyle = .reveal
    options.buttonVerticalAlignment = .center
    return options
  }
  
  override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = convertSPTTrackToEQTrack(sptTrack: songlists[indexPath.row])
    
    guard let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) else {
      return
    }
    if added {
      if let index = self.eqSettingManager?.tempModel.tracks.index(where: {
        $0.uri == track.uri
      }) {
        self.eqSettingManager?.tempModel.tracks.remove(at: index)
      }
    } else {
      self.eqSettingManager?.tempModel.tracks.append(track)
    }
    eqSettingManager?.isModify = true
    EQNotifycationCenterManager.post(name: Notification.Name.eqProjectTrackModifyNotification)
    self.tableView.reloadDataUpdateFade()
  }
}

extension EQSonglistTableViewController: EQSonglistTableViewCellDelegate {
  func didPreviewButtonClick(indexPath: IndexPath) {
    guard  let cell = tableView.cellForRow(at: indexPath) as? EQSonglistTableViewCell else {
      return
    }
    let track = songlists[indexPath.row]
    if previousPreviewIndex != indexPath {
      //按別的cell
      resetCell(indexPath: previousPreviewIndex)
    }
    if cell.previewButton.isSelected {
      //試聽的那個
      previousPreviewIndex = indexPath
      previousPreviewURLString = track.uri.absoluteString
      EQSpotifyManager.shard.durationObseve.previewCurrentDuration = 0
      EQSpotifyManager.shard.playPreview(uri: track.uri.absoluteString, duration: track.duration)
      {
        cell.obsevePreviewDuration()
        cell.startObseve()
        self.tableView.reloadDataUpdateFade()
      }

    } else {
      //按自己
      resetCell(indexPath: indexPath)
      EQSpotifyManager.shard.player?.setIsPlaying(false, callback: nil)
    }
  }
  
  func resetCell(indexPath: IndexPath?, currentIndex: IndexPath) {
    guard let resetIndexPath = indexPath,
      let cell = tableView.cellForRow(at: resetIndexPath) as? EQSonglistTableViewCell,
      let currentCell = tableView.cellForRow(at: currentIndex) as? EQSonglistTableViewCell  else {
      return
    }
    if currentCell.previewButton.isSelected {
      return
    }
    cell.timer?.invalidate()
    cell.previewProgressBar.progress = 0
    cell.previewButton.isSelected = false
  }
  func resetCell(indexPath: IndexPath?) {
    guard let resetIndexPath = indexPath,
      let cell = tableView.cellForRow(at: resetIndexPath) as? EQSonglistTableViewCell else {
        return
    }
    
    cell.timer?.invalidate()
    cell.previewProgressBar.progress = 0
    cell.previewButton.isSelected = false
  }
}
