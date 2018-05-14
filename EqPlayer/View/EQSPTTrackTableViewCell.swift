//
//  EQSPTTrackTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import SDWebImage
import UIKit

class EQSPTTrackTableViewCell: UITableViewCell {
    @IBOutlet var albumImage: UIImageView!

    @IBOutlet var trackTitle: UILabel!

    @IBOutlet var artistLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        albumImage.layer.cornerRadius = 10
        albumImage.clipsToBounds = true
        // Initialization code
    }

    func setupCell(albumPic: URL?, title: String?, artist: [SPTPartialArtist]?) {
        if albumPic != nil {
            albumImage.sd_setImage(with: albumPic, completed: nil)
        }
        guard let artists = artist else {
            return
        }
        var artistsString: String = ""
        artists.forEach { artist in
            artistsString += artist.name + " "
        }
        artistLabel.text = artistsString
        trackTitle.text = title ?? ""
    }
}
