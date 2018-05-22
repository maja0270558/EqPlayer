//
//  EQConstraintExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/23.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension NSLayoutConstraint {
  func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
    
    NSLayoutConstraint.deactivate([self])
    
    let newConstraint = NSLayoutConstraint(
      item: firstItem,
      attribute: firstAttribute,
      relatedBy: relation,
      toItem: secondItem,
      attribute: secondAttribute,
      multiplier: multiplier,
      constant: constant)
    
    newConstraint.priority = priority
    newConstraint.shouldBeArchived = self.shouldBeArchived
    newConstraint.identifier = self.identifier
    
    NSLayoutConstraint.activate([newConstraint])
    return newConstraint
  }
}
