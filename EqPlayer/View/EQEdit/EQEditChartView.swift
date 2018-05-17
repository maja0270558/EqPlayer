//
//  EQEditChartView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
protocol EQEditChartViewDelegate: class{
    func saveButtonDidClick()
    func postButtonDidClick()
}
class EQEditChartView: UIView {
    weak var delegate: EQEditChartViewDelegate?
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBAction func saveAction(_ sender: UIButton) {
        delegate?.saveButtonDidClick()
    }
    @IBAction func postAction(_ sender: UIButton) {
        delegate?.postButtonDidClick()
    }
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var postButton: UIButton!
    func setupLineChart(){
        //MARK: Y axis
        lineChartView.leftAxis.drawGridLinesEnabled = false
        lineChartView.leftAxis.drawAxisLineEnabled = false
        lineChartView.leftAxis.drawLabelsEnabled = false
        lineChartView.leftAxis.axisMinimum = -25
        lineChartView.leftAxis.axisMaximum = 30
        lineChartView.rightAxis.axisMinimum = -25
        lineChartView.rightAxis.axisMaximum = 30
        lineChartView.rightAxis.drawGridLinesEnabled = false
        lineChartView.rightAxis.drawAxisLineEnabled = false
        lineChartView.rightAxis.drawLabelsEnabled = false
        //MARK: X axis
        let xValueLabels = ["25", "40", "63", "100", "160", "250", "400", "640", "1k", "1.6k", "2.5k", "4k", "6.3k", "10k", "16k"]
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.drawAxisLineEnabled = false
        lineChartView.xAxis.drawLabelsEnabled = true
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: xValueLabels)
        lineChartView.xAxis.avoidFirstLastClippingEnabled = true
        lineChartView.xAxis.drawLimitLinesBehindDataEnabled = true
        lineChartView.xAxis.granularityEnabled = true
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelCount = xValueLabels.count
        lineChartView.xAxis.labelTextColor = UIColor.white
        
        //MARK: Global
        lineChartView.highlightPerTapEnabled = false
        lineChartView.dragEnabled = true
        lineChartView.pinchZoomEnabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.chartDescription?.enabled = false
        lineChartView.legend.enabled = false
        setChart(15)
    }
    func setChart(_ count: Int) {
        let value = (0..<count).map({
            index -> ChartDataEntry in
            let val = Double(0)
            return ChartDataEntry(x: Double(index), y: val)
        })
        let set = LineChartDataSet(values: value, label: "")
        
        //MARK: Custom style
        let gradientColors = [UIColor.green.cgColor, UIColor.clear.cgColor] as CFArray
        let colorLocations:[CGFloat] = [0.8, 0]
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
        set.drawFilledEnabled = true
        set.mode = .cubicBezier
        set.valueTextColor = UIColor.white
        let data = LineChartData(dataSets: [set])
        self.lineChartView.data = data
    }
    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
    }
    func styleButtons(){
        setupButton(saveButton)
        setupButton(postButton)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        styleButtons()
        setupLineChart()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        styleButtons()
        setupLineChart()
    }
}
