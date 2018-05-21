//
//  EQLineChartViewExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/21.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import Charts
enum EQChartViewStyle {
  case edit
  case cell
}
extension LineChartView {
  func setChart(_ count: Int, color: UIColor, style: EQChartViewStyle = .edit) {
    let value = (0 ..< count).map({ index -> ChartDataEntry in
      let val = Double(25)
      return ChartDataEntry(x: Double(index), y: val)
    })
   
    let set = LineChartDataSet(values: value, label: "")
    let gradientColors = [color.cgColor, UIColor.clear.cgColor] as CFArray
    var colorLocations: [CGFloat] = [0.8, 0]
    set.setColor(NSUIColor(cgColor: color.cgColor))
    switch style {
    case .edit:
      set.drawValuesEnabled = true
      set.valueTextColor = UIColor.white
      set.setCircleColor(NSUIColor(cgColor: color.cgColor))
      set.circleHoleColor = NSUIColor(cgColor: UIColor.white.cgColor)
      set.circleRadius = 6
      set.circleHoleRadius = set.circleRadius/3
    case .cell:
      set.drawValuesEnabled = false
      set.drawCircleHoleEnabled = false
      set.drawCirclesEnabled = false
      set.lineWidth = 2
      colorLocations = [0.3,0]
    }
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
    set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
    set.drawFilledEnabled = true
    set.mode = .cubicBezier

    let data = LineChartData(dataSets: [set])
    self.data = data
  }
  
  func getEntryValues() -> [Double]{
    var yValues = [Double]()

    guard let xCount = self.lineData?.dataSets.first?.entryCount else {
      return yValues
    }
    
    for index in stride(from: 0, to: xCount, by: 1) {
      if let yValue = self.lineData?.dataSets.first?.entryForIndex(index)?.y {
        yValues.append(yValue)
      }
    }
    return yValues
  }
  
  func setEntryValue(yValues: [Double]){
    
    guard let xCount = self.lineData?.dataSets.first?.entryCount else {
      return
    }
    for index in stride(from: 0, to: yValues.count, by: 1) {
      if let xEntry = self.lineData?.dataSets.first?.entryForIndex(index) {
        xEntry.y = yValues[index]
      }
    }
  }
  
  func configStyle(_ style: EQChartViewStyle) {
    self.leftAxis.axisMinimum = -25
    self.leftAxis.axisMaximum = 30
    self.rightAxis.axisMinimum = -25
    self.rightAxis.axisMaximum = 30
    self.leftAxis.drawGridLinesEnabled = false
    self.leftAxis.drawAxisLineEnabled = false
    self.leftAxis.drawLabelsEnabled = false
    self.rightAxis.drawGridLinesEnabled = false
    self.rightAxis.drawAxisLineEnabled = false
    self.rightAxis.drawLabelsEnabled = false
    self.xAxis.drawGridLinesEnabled = false
    self.xAxis.drawAxisLineEnabled = false
    
    switch style {
    case .edit:
      let xValueLabels = ["25", "40", "63", "100", "160", "250", "400", "640", "1k", "1.6k", "2.5k", "4k", "6.3k", "10k", "16k"]
      self.xAxis.drawLabelsEnabled = true
      self.xAxis.labelPosition = .bottom
      self.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValueLabels)
      self.xAxis.avoidFirstLastClippingEnabled = true
      self.xAxis.drawLimitLinesBehindDataEnabled = true
      self.xAxis.granularityEnabled = true
      self.xAxis.granularity = 1
      self.xAxis.labelCount = xValueLabels.count
      self.xAxis.labelTextColor = UIColor.white
      self.dragEnabled = true
    case .cell:
      self.xAxis.labelCount = 0
      self.dragEnabled = false
      self.alpha = 1

    }
    // MARK: Global
    self.highlightPerTapEnabled = false
    self.pinchZoomEnabled = false
    self.scaleXEnabled = false
    self.scaleYEnabled = false
    self.chartDescription?.enabled = false
    self.legend.enabled = false
  }
}
