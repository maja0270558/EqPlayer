//
//  EQSelectTrackTopCollectionViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

protocol EQSelectTrackTopCollectionViewCellProtocol: class {
    func didClickCancelButton()
    func didClickBackButton()
}

class EQSelectTrackTopCollectionViewCell: UICollectionViewCell {
    weak var delegate: EQSelectTrackTopCollectionViewCellProtocol?

    @IBAction func backAction(_: UIButton) {
        delegate?.didClickBackButton()
    }

    @IBAction func cancelAction(_: UIButton) {
        delegate?.didClickCancelButton()
    }

    @IBOutlet var backButton: UIButton!
    @IBOutlet var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func resetCell() {
        backButton.isHidden = false
    }

    func setupAlpha(currentIndex: CGFloat, cellRow: CGFloat) {
        var scale = fabs(currentIndex - cellRow)
        if scale > 1 {
            scale = 1
        }
        alpha = 1 - scale
        layoutIfNeeded()
    }
}
