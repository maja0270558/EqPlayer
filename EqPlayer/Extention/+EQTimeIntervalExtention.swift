//
//  +EQTimeIntervalExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/24.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

extension TimeInterval {
  func stringFromTimeInterval() -> String {
    let formatter = DateComponentsFormatter()
    formatter.zeroFormattingBehavior = .pad
    formatter.allowedUnits = [.minute, .second]
    if self >= 3600 {
      formatter.allowedUnits.insert(.hour)
    }
    return formatter.string(from: self)!
  }

}
