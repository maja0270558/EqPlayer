//
//  EQSPTTrackTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import SDWebImage
import SwipeCellKit
import UIKit

class EQSPTTrackTableViewCell: SwipeTableViewCell {
    @IBOutlet var albumImage: UIImageView!

    @IBOutlet var trackTitle: UILabel!

    @IBOutlet var artistLabel: UILabel!

    @IBOutlet var checkedWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        albumImage.layer.cornerRadius = 10
        albumImage.clipsToBounds = true
        // Initialization code
    }

    func setupCell(coverURLString: String?, title: String, artist: String) {
        if let coverURL = coverURLString {
            albumImage.sd_setImage(with:URL(string: coverURL), completed: nil)
        }
        artistLabel.text = artist
        trackTitle.text = title
    }
}
