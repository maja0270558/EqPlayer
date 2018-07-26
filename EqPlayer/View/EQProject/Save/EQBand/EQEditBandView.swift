//
//  EQEditBandView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/15.
//  Copyright © 2018年 Django. All rights reserved.
//

import Charts
import UIKit
protocol EQEditBandViewDelegate: class {
    func didClickSaveProjectButton()
    func didClickPostProjectButton()
    func didClickDismissButton()
}

class EQEditBandView: UIView {
    @IBOutlet var projectNameTextField: UITextField!
    weak var delegate: EQEditBandViewDelegate?
    @IBOutlet var lineChartView: LineChartView!

    @IBAction func saveAction(_: UIButton) {
        delegate?.didClickSaveProjectButton()
    }

    @IBAction func postAction(_: UIButton) {
        delegate?.didClickPostProjectButton()
    }

    @IBAction func dismissAction(_: UIButton) {
        delegate?.didClickDismissButton()
    }

    @IBOutlet var saveButton: UIButton!

    @IBOutlet var postButton: UIButton!

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        lineChartView.configStyle(.edit)
        lineChartView.setChart(15, color: UIColor.orange, style: .edit)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        lineChartView.configStyle(.edit)
        lineChartView.setChart(15, color: UIColor.orange, style: .edit)
    }
}
