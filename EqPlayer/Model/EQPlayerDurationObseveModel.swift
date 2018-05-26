//
//  EQPlayerDurationObseveModel.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/26.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQPlayerDurationObseveModel: NSObject {
  @objc dynamic var currentDuration: Double = 0
  @objc dynamic var previewCurrentDuration: Double = 0
  var maxPreviewDuration: Double = 0
  var maxDuration: Double = 0
}
