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

    //  override func layoutSubviews() {
//    super.layoutSubviews()
//    self.addTarget(nil, action: #selector(resize), for: .touchUpOutside)
//    self.addTarget(nil, action: #selector(resize), for: .touchUpInside)
//    self.addTarget(nil, action: #selector(scale), for: .touchDown)
    //  }
    //  @objc func scale() {
//    UIView.animate(withDuration: 0.3) {
//      self.subviews[2].transform = CGAffineTransform(scaleX: 3, y: 3)
//    }
    //  }
    //  @objc func resize() {
//    UIView.animate(withDuration: 0.3) {
//      self.subviews[2].transform = CGAffineTransform.identity
//    }
    //  }
}
