//
//  DefaultSettingCollectionViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/7/4.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class DefaultSettingCollectionViewCell: UICollectionViewCell {
  
  @IBOutlet weak var settingTitle: UILabel!
  @IBOutlet weak var settingBackgroundView: UIView!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        settingBackgroundView.layer.cornerRadius = settingBackgroundView.bounds.height/3
        settingBackgroundView.clipsToBounds = true
    }

}
