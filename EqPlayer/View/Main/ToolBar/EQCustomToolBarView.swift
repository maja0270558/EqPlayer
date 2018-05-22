//
//  UserInfoHeaderView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol EQCustomToolBarDataSource: class {
  func eqToolBarNumberOfItem() -> Int
  func eqToolBar(titleOfItemAt: Int) -> String
}

protocol EQCustomToolBarDelegate: class {
  func eqToolBar(didSelectAt: Int)
}

class EQCustomToolBarView: UIView {
  @IBOutlet var toolBar: UIToolbar!
  @IBOutlet var caProgress: UIView!
  weak var delegate: EQCustomToolBarDelegate?
  weak var datasource: EQCustomToolBarDataSource? {
    didSet {
      setupToolBar()
    }
  }
  
  private var progressBarLayer: CAShapeLayer?
  private var progressBarPath: UIBezierPath?
  private var startAnimation: CABasicAnimation?
  private var endAnimation: CABasicAnimation?
  private var preIndex: Float = 0
  private var preStartPoint: CGFloat = 0
  private var preEndPoint: CGFloat = 0
  private var itemCount: Float {
    return Float(datasource!.eqToolBarNumberOfItem())
  }
  private var buttonArray = [UIBarButtonItem]()
  var duration: Double = 0.15
  var strokeColor: UIColor = UIColor.orange
  
  private var isAnimating: Bool = false
  func setupToolBar() {
    guard let datasource = datasource else {
      return
    }
    let numberOfItem = datasource.eqToolBarNumberOfItem()
    var items = [UIBarButtonItem]()
    let total = numberOfItem * 2 + 1
    for index in 0 ... total - 1 {
      if index % 2 >= 1 {
        let buttonTag = (index - 1) / 2
        let barButton = UIBarButtonItem(title: datasource.eqToolBar(titleOfItemAt: buttonTag), style: .plain, target: self, action: #selector(onToolBarItemTapped(sender:)))
        barButton.tag = buttonTag
        items.append(barButton)
        buttonArray.append(barButton)
      } else {
        let emptyFlexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        items.append(emptyFlexSpace)
      }
    }
    toolBar.setItems(items, animated: false)
    resetBarItemAlpha()
    buttonArray.first?.tintColor = UIColor.white
    animateProgress(toIndex: 0)
  }
  
  private func resetBarItemAlpha() {
    buttonArray.forEach {
      $0.tintColor = UIColor.white.withAlphaComponent(0.5)
    }
  }
  
  @objc func onToolBarItemTapped(sender: UIBarButtonItem) {
    guard let delegate = delegate else {
      return
    }
    if isAnimating {
      return
    }
    UIView.animate(withDuration: 0.2) {
      self.resetBarItemAlpha()
      sender.tintColor = UIColor.white
    }
    animateProgress(toIndex: Float(sender.tag))
    delegate.eqToolBar(didSelectAt: sender.tag)
  }
  
  func setupBezierPath() {
    self.progressBarPath = UIBezierPath()
    guard let progressBarPath = self.progressBarPath else { return }
    progressBarPath.move(to: CGPoint(x: 0, y: caProgress.bounds.height - 8))
    progressBarPath.addLine(to: CGPoint(x: UIScreen.main.bounds.width, y: caProgress.bounds.height - 8))
  }
  
  func setupLayer() {
    self.progressBarLayer = CAShapeLayer()
    guard let progressBarLayer = self.progressBarLayer else { return }
    progressBarLayer.path = progressBarPath?.cgPath
    progressBarLayer.lineWidth = 4.0
    progressBarLayer.strokeColor = strokeColor.cgColor
    progressBarLayer.fillColor = UIColor.clear.cgColor
    progressBarLayer.strokeEnd = 0
    progressBarLayer.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
    caProgress.layer.addSublayer(progressBarLayer)
  }
  
  func setupCAAnimation() {
    startAnimation = CABasicAnimation(keyPath: "strokeStart")
    endAnimation = CABasicAnimation(keyPath: "strokeEnd")
  }
  
  func animateProgress(toIndex: Float) {
    if let startAnim = startAnimation, let endAnim = endAnimation {
      isAnimating = true
      let targetStartPoint = CGFloat(toIndex / itemCount)
      let targetEndPoint = CGFloat((toIndex + 1) / itemCount)
      startAnim.fromValue = preStartPoint
      endAnim.fromValue = preEndPoint
      startAnim.toValue = targetStartPoint
      endAnim.toValue = targetEndPoint
      startAnim.duration = duration
      endAnim.duration = duration
      startAnim.isRemovedOnCompletion = false
      endAnim.isRemovedOnCompletion = false
      startAnim.fillMode = kCAFillModeForwards
      endAnim.fillMode = kCAFillModeForwards
      if toIndex > preIndex {
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
          CATransaction.begin()
          CATransaction.setCompletionBlock { [weak self] in
            self?.isAnimating = false
          }
          self?.progressBarLayer?.add(startAnim, forKey: "ProgressStartAnimation")
          CATransaction.commit()
        }
        progressBarLayer?.add(endAnim, forKey: "ProgressEndAnimation")
        CATransaction.commit()
      } else {
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
          CATransaction.begin()
          CATransaction.setCompletionBlock { [weak self] in
            self?.isAnimating = false
          }
          self?.progressBarLayer?.add(endAnim, forKey: "ProgressEndAnimation")
          CATransaction.commit()
        }
        progressBarLayer?.add(startAnim, forKey: "ProgressStartAnimation")
        CATransaction.commit()
      }
      preStartPoint = targetStartPoint
      preEndPoint = targetEndPoint
      preIndex = toIndex
    }
  }
  
  func caProgressBarInit() {
    setupBezierPath()
    setupLayer()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    fromNib()
    setupCAAnimation()
    caProgressBarInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    fromNib()
    setupCAAnimation()
    caProgressBarInit()
  }
}
