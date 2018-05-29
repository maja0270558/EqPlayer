//
//  EQSonglistTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import SDWebImage
import SwipeCellKit
import MediaPlayer
import UIKit

protocol EQSonglistTableViewCellDelegate: class {
  func didPreviewButtonClick(indexPath: IndexPath)
}

class EQSonglistTableViewCell: SwipeTableViewCell {
    weak var cellDelegate: EQSonglistTableViewCellDelegate?
  
  @IBOutlet weak var previewProgressBar: UIProgressView!
  
  @IBOutlet var albumImage: UIImageView!

    @IBOutlet var trackTitle: UILabel!

    @IBOutlet var artistLabel: UILabel!

    @IBOutlet var checkedWidthConstraint: NSLayoutConstraint!
  
    var previewCurrentDuration:Double = 0
  
    var indexPath: IndexPath?
  
    @IBAction func previewAction(_ sender: UIButton) {
      self.previewButton.isSelected = !self.previewButton.isSelected
      EQNotifycationCenterManager.post(name: Notification.Name.eqProjectPlayPreviewTrack)
      self.cellDelegate?.didPreviewButtonClick(indexPath: self.indexPath!)
    }
    var track: EQTrack?
  
    @IBOutlet weak var previewButton: UIButton!
    var timer: Timer?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectedColor()
        albumImage.layer.cornerRadius = 10
        albumImage.clipsToBounds = true
    }
  
    func startObseve() {
      timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(obsevePreviewDuration), userInfo: nil, repeats: true)
    }
  
    @objc func obsevePreviewDuration() {
      let maxDuration = EQSpotifyManager.shard.durationObseve.maxPreviewDuration
      EQSpotifyManager.shard.durationObseve.previewCurrentDuration += 0.25
      let duration = EQSpotifyManager.shard.durationObseve.previewCurrentDuration
      let progress = duration/maxDuration
      if duration > maxDuration {
        EQSpotifyManager.shard.player?.setIsPlaying(false, callback: nil)
        previewButton.isSelected = false
        previewCurrentDuration = 0
        previewProgressBar.progress = 0
        timer?.invalidate()
        return
      }
        self.previewProgressBar.progress = Float(progress)
      }

    func setupCell(coverURLString: String?, title: String, artist: String) {
        if let coverURL = coverURLString {
          albumImage.sd_setImage(with: URL(string: coverURL), placeholderImage: #imageLiteral(resourceName: "quaver-outline"), options: [], completed: nil)
        }
        artistLabel.text = artist
        trackTitle.text = title
    }
}
