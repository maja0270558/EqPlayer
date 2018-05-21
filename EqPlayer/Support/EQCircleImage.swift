//
//  EQCircleImage.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQCircleImage: UIImageView {
  override func layoutSubviews() {
    super.layoutSubviews()
    let radius: CGFloat = bounds.size.width / 2.0
    layer.cornerRadius = radius
    clipsToBounds = true
  }
}
