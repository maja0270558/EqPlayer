//
//  EQLineChartViewExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/21.
//  Copyright © 2018年 Django. All rights reserved.
//

import Charts
import Foundation
enum EQChartViewStyle {
    case edit
    case cell
}

extension LineChartView {
    func setChart(_ count: Int, color: UIColor, style: EQChartViewStyle = .edit) {
        let value = (0 ..< count).map({ index -> ChartDataEntry in
            let val = Double(0)
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
            set.circleHoleRadius = set.circleRadius / 3
        case .cell:
            set.drawHorizontalHighlightIndicatorEnabled = false
            set.drawVerticalHighlightIndicatorEnabled = false
            set.drawValuesEnabled = false
            set.drawCircleHoleEnabled = false
            set.drawCirclesEnabled = false
            set.lineWidth = 2
            colorLocations = [0.3, 0]
        }
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        set.drawFilledEnabled = true
        set.mode = .cubicBezier

        let data = LineChartData(dataSets: [set])
        self.data = data
    }

    func getEntryValues() -> [Double] {
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

    func setEntryValue(yValues: [Double]) {
        for index in stride(from: 0, to: yValues.count, by: 1) {
            if let xEntry = self.lineData?.dataSets.first?.entryForIndex(index) {
                xEntry.y = yValues[index]
                self.notifyDataSetChanged()
            }
        }
    }

    func configStyle(_ style: EQChartViewStyle) {
        leftAxis.axisMinimum = -12
        leftAxis.axisMaximum = 15
        rightAxis.axisMinimum = -12
        rightAxis.axisMaximum = 15
        leftAxis.drawGridLinesEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawLabelsEnabled = false
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawAxisLineEnabled = false
        rightAxis.drawLabelsEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.drawLabelsEnabled = false
        switch style {
        case .edit:
            let xValueLabels = ["25", "40", "63", "100", "160", "250", "400", "640", "1k", "1.6k", "2.5k", "4k", "6.3k", "10k", "16k"]
            xAxis.drawLabelsEnabled = true
            xAxis.labelPosition = .bottom
            xAxis.valueFormatter = IndexAxisValueFormatter(values: xValueLabels)
            xAxis.avoidFirstLastClippingEnabled = true
            xAxis.drawLimitLinesBehindDataEnabled = true
            xAxis.granularityEnabled = true
            xAxis.granularity = 1
            xAxis.labelCount = xValueLabels.count
            xAxis.labelTextColor = UIColor.white
            dragEnabled = true
        case .cell:
            xAxis.labelCount = 0
            xAxis.drawLabelsEnabled = false
            xAxis.labelPosition = .bottom
            dragEnabled = false
            alpha = 1
        }

        // MARK: Global

        highlightPerTapEnabled = false
        pinchZoomEnabled = false
        scaleXEnabled = false
        scaleYEnabled = false
        chartDescription?.enabled = false
        legend.enabled = false
    }
}
