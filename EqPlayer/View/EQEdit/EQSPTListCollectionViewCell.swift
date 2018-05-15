//
//  EQSPTListCollectionViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/14.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

protocol EQSPTListCollectionViewCellProtocol: class {
    func didCancelButtonClick()
    func didBackButtonClick()
}

class EQSPTListCollectionViewCell: UICollectionViewCell {
    weak var delegate: EQSPTListCollectionViewCellProtocol?

    @IBAction func backAction(_: UIButton) {
        delegate?.didBackButtonClick()
    }

    @IBAction func cancelAction(_: UIButton) {
        delegate?.didCancelButtonClick()
    }

    @IBOutlet var backButton: UIButton!

    @IBOutlet var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
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
