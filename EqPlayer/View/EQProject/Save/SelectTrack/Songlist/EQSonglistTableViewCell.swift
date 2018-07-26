//
//  EQSonglistTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import MediaPlayer
import SDWebImage
import MGSwipeTableCell
import UIKit

class EQSonglistTableViewCell: MGSwipeTableCell {
    @IBOutlet var previewProgressBar: UIProgressView!
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var trackTitle: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var checkedWidthConstraint: NSLayoutConstraint!
    var previewCurrentDuration: Double = 0
    var indexPath: IndexPath?
    var track: EQTrack?

    @IBOutlet var previewButton: UIButton!
    @objc var timer: Timer?

    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectedColor()
        albumImage.layer.cornerRadius = 10
        albumImage.clipsToBounds = true
        rightExpansion.buttonIndex = 0
        rightExpansion.threshold = 4
        selectionStyle = .none
        rightSwipeSettings.transition = .border
    }

    @objc func startObseve() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(obsevePreviewDuration), userInfo: nil, repeats: true)
    }

    @objc func obsevePreviewDuration() {
        let maxDuration = EQSpotifyManager.shard.durationObseve.maxPreviewDuration
        EQSpotifyManager.shard.durationObseve.previewCurrentDuration += 0.25
        let duration = EQSpotifyManager.shard.durationObseve.previewCurrentDuration
        let progress = duration / maxDuration
        if duration > maxDuration {
            EQSpotifyManager.shard.currentPlayingType = .project
            EQSpotifyManager.shard.playOrPause(isPlay: false)
            previewButton.isSelected = false
            previewCurrentDuration = 0
            previewProgressBar.progress = 0
            timer?.invalidate()
            return
        }
        previewProgressBar.progress = Float(progress)
    }

    @objc func configureCellWith(cellModel: EQTrackCellModel, swipeCallback: ((MGSwipeTableCell) -> Bool)?) {
        checkedWidthConstraint.constant = cellModel.constraintWidth;
        artistLabel.text = cellModel.artist
        trackTitle.text = cellModel.trackName
        swipeBackgroundColor = cellModel.swipeColor
        if let coverURL = cellModel.coverURL {
            albumImage.sd_setImage(with: URL(string: coverURL), placeholderImage: #imageLiteral(resourceName: "quaver-outline"), options: [], completed: nil)
        }
        self.rightButtons = [MGSwipeButton(title: "", icon: cellModel.swipeImage, backgroundColor: cellModel.swipeColor, callback: swipeCallback)]
        
    }
    
    @objc func setupCell(coverURLString: String?, title: String, artist: String) {
        if let coverURL = coverURLString {
            albumImage.sd_setImage(with: URL(string: coverURL), placeholderImage: #imageLiteral(resourceName: "quaver-outline"), options: [], completed: nil)
        }
        artistLabel.text = artist
        trackTitle.text = title
    }
}
