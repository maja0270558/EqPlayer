//
//  EQUserInfoTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQUserInfoTableViewCell: UITableViewCell {
    @IBOutlet var userImage: EQCircleImage!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var userName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        if EQUserManager.shard.userStatus == .guest {
            cameraButton.isHidden = true
        }
        setSelectedColor(color: UIColor.clear)
    }
}
