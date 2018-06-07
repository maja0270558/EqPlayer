//
//  EQCustomHitTestUIView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQCustomHitTestUIView: UIView {
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    if hitView == self {
      return nil
    }
    else {
      return hitView
    }
  }
}
