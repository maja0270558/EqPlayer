//
//  EQCustomSlider.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
@IBDesignable
class EQCustomSlider: UISlider {
  @IBInspectable var thumbImage: UIImage? {
    didSet {
      let image = thumbImage?.resizeImage(targetSize: CGSize(width: 5, height: 5))
      setThumbImage(image, for: .normal)
      setThumbImage(image, for: .highlighted)
    }
  }

}
