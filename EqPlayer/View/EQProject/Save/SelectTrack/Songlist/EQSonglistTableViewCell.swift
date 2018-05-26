//
//  EQSonglistTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import SDWebImage
import SwipeCellKit
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

    var indexPath: IndexPath?
  
    @IBAction func previewAction(_ sender: UIButton) {
      previewButton.isSelected = !previewButton.isSelected
      cellDelegate?.didPreviewButtonClick(indexPath: indexPath!)
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
      let duration = (maxDuration + EQSpotifyManager.shard.durationObseve.previewCurrentDuration)/maxDuration
      previewProgressBar.progress = Float(1 - duration)
    }

    func setupCell(coverURLString: String?, title: String, artist: String) {
        if let coverURL = coverURLString {
          albumImage.sd_setImage(with: URL(string: coverURL), placeholderImage: #imageLiteral(resourceName: "quaver-outline"), options: [], completed: nil)
        }
        artistLabel.text = artist
        trackTitle.text = title
    }
}
