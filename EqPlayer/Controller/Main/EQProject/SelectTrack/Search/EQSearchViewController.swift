//
//  EQSearchViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import SwipeCellKit

protocol EQSearchViewControllerDelegate: class {
  func didDismiss()
}

class EQSearchViewController: UIViewController {
  weak var delegate: EQSearchViewControllerDelegate?
  var eqSettingManager: EQSettingModelManager?
  var songlists = [SPTPartialTrack]()
  var previousPreviewIndex: IndexPath?
  
  @IBOutlet weak var searchBar: EQCustomSearchBar!
  
  @IBOutlet weak var cancelButton: UIButton!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBAction func cancelAction(_ sender: UIButton) {
    dismiss(animated: true) {
      self.delegate?.didDismiss()
    }
  }
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupTableView()
    setupSearchBar()
  }
  func setupTableView() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.registeCell(cellIdentifier: EQSonglistTableViewCell.typeName)
    tableView.backgroundColor = UIColor.clear
    tableView.separatorStyle = .none
  }
  func setupSearchBar(){
    let searchBarBackground = UIImage.roundedImage(image: UIImage.imageWithColor(color: UIColor.clear, size: CGSize(width: 28, height: 28)), cornerRadius: 2)
    searchBar.setSearchFieldBackgroundImage(searchBarBackground, for: .normal)
    cancelButton.alpha = 0
    UIView.animate(withDuration: 0.4) {
      self.cancelButton.alpha = 1
    }
    searchBar.becomeFirstResponder()
    searchBar.delegate = self
  }
}

extension EQSearchViewController: TableViewDelegateAndDataSource {
  func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return songlists.count
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    resetCell(indexPath: indexPath)
  }
  
  func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: EQSonglistTableViewCell.typeName, for: indexPath) as?
      EQSonglistTableViewCell else {
        return UITableViewCell()
    }
    
    let track = convertSPTTrackToEQTrack(sptPartialTrack: songlists[indexPath.row])
    
    if let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) {
      if added {
        cell.checkedWidthConstraint.constant = 20
      } else {
        cell.checkedWidthConstraint.constant = 0
      }
    }
    
    cell.delegate = self
    cell.cellDelegate = self
    cell.indexPath = indexPath
    cell.track = track
    cell.selectionStyle = .none
    cell.setupCell(coverURLString: track.coverURL, title: track.name, artist: track.artist)
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
  
  func tableView(_: UITableView, estimatedHeightForRowAt _: IndexPath) -> CGFloat {
    return 100
  }
}


extension EQSearchViewController {
  func scrollViewDidScroll(_: UIScrollView) {
    tableView.fadeTopCell()
  }
}

extension EQSearchViewController: SwipeTableViewCellDelegate {
  func convertSPTTrackToEQTrack(sptPartialTrack: SPTPartialTrack) -> EQTrack {
    let eqTrack = EQTrack()
    
    if let previewURL = sptPartialTrack.previewURL {
      eqTrack.previewURL = previewURL.absoluteString
    }
    
    if let imageURL = sptPartialTrack.album.largestCover {
      eqTrack.coverURL = imageURL.imageURL.absoluteString
    }
    
    guard let title = sptPartialTrack.name, let artists = sptPartialTrack.artists as? [SPTPartialArtist] else {
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
    eqTrack.uri = sptPartialTrack.uri.absoluteString
    eqTrack.duration = sptPartialTrack.duration
    return eqTrack
  }
  
  func tableView(_: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    let track = convertSPTTrackToEQTrack(sptPartialTrack: songlists[indexPath.row])
    
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
      self.eqSettingManager?.isModify = true
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
    let track = convertSPTTrackToEQTrack(sptPartialTrack: songlists[indexPath.row])
    
    if let added = eqSettingManager?.tempModel.tracks.contains(where: { $0.uri == track.uri }) {
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
  
  func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
    let track = convertSPTTrackToEQTrack(sptPartialTrack: songlists[indexPath.row])
    
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

extension EQSearchViewController: EQSonglistTableViewCellDelegate {
  func didPreviewButtonClick(indexPath: IndexPath) {
    guard  let cell = tableView.cellForRow(at: indexPath) as? EQSonglistTableViewCell else {
      return
    }
    let track = songlists[indexPath.row]
    if cell.previewButton.isSelected {
      //試聽的那個
      resetAllVisibleCell()
      previousPreviewIndex = indexPath
      EQSpotifyManager.shard.previousPreviewURLString = track.uri.absoluteString
      EQSpotifyManager.shard.playPreview(uri: track.uri.absoluteString, duration: track.duration)
      {
        EQSpotifyManager.shard.durationObseve.previewCurrentDuration = 0
        cell.startObseve()
        cell.previewButton.isSelected = true
        EQNotifycationCenterManager.post(name: Notification.Name.eqProjectPlayPreviewTrack)
      }
      
    } else {
      //按自己
      EQSpotifyManager.shard.player?.setIsPlaying(false, callback: {error in
        if error != nil {
          return
        }
        EQSpotifyManager.shard.currentPlayingType = .project
        self.resetCell(indexPath: indexPath)
      })
    }
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
  
  func resetAllVisibleCell() {
    guard let cells = tableView.visibleCells as? [EQSonglistTableViewCell] else {
      return
    }
    cells.forEach { (cell) in
      cell.timer?.invalidate()
      cell.previewProgressBar.progress = 0
      cell.previewButton.isSelected = false
    }
  }
}

extension EQSearchViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if (searchBar.text?.isEmpty)! {
      dismiss(animated: true) {
        self.delegate?.didDismiss()
      }
    }
    searchBar.resignFirstResponder()
  }
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      songlists.removeAll()
      tableView.reloadData()
    }
    fetchTrack(query: searchText)
  }
  
  func fetchTrack(query: String) {
    SPTSearch.perform(withQuery: query, queryType: .queryTypeTrack, accessToken: EQSpotifyManager.shard.auth?.session.accessToken) { (error, listPage) in
      guard let listPage = listPage as? SPTListPage else { return }
      guard let tracks = listPage.items as? [SPTPartialTrack] else { return }
      self.songlists = tracks
      self.tableView.reloadData()
    }
  }
}
