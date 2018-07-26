//
//  EQPlaylistTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQPlaylistTableViewCell: UITableViewCell {
    @IBOutlet var playlistNameLabel: UILabel!
    @IBOutlet var numberOfTrackLabel: UILabel!

    func setupCell(listname: String, numberOfTrack: Int) {
        playlistNameLabel.text = listname
        numberOfTrackLabel.text = "\(numberOfTrack) Tracks"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setSelectedColor()
        // Initialization code
    }
}
