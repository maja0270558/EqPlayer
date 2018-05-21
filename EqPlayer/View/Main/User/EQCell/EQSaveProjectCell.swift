//
//  EQSaveProjectCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
class EQSaveProjectCell: UITableViewCell {
  @IBOutlet weak var playlistCover: EQCircleImage!
  @IBOutlet weak var cellEQChartView: LineChartView!
  @IBOutlet weak var projectTitleLabel: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        cellEQChartView.configStyle(.cell)
        cellEQChartView.setChart(15, color: UIColor.green, style: .cell)
        // Initialization code
    }

}
