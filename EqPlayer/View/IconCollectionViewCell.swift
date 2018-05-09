//
//  IconCollectionViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class IconCollectionViewCell: UICollectionViewCell {
    var originalIconSize: CGSize = CGSize.zero
    @IBOutlet var iconImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupImageSize(size: CGSize, currentIndex: CGFloat, cellRow: CGFloat) {
        originalIconSize = size
        var scale = fabs(currentIndex - cellRow)
        if scale > 1 {
            scale = 1
        }
        let scaleFactor = scale * 0.4
        let cellWidth = originalIconSize.width
        let cellHeigh = originalIconSize.height
        let finalSize = CGSize(width: cellWidth - (cellWidth * scaleFactor), height: cellHeigh - (cellHeigh * scaleFactor))

        iconImageView.bounds.size = finalSize
        layoutIfNeeded()
    }
}
