//
//  EQPlayerView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Lerp
public protocol EQPlayerViewDelegate: class {
  func didClapPlayer()
  func didOpenPlayer()
}
class EQPlayerView: EQPlayerPannableView {
  weak var delegate: EQPlayerViewDelegate?
 
  var maxCoverWidth: CGFloat {
    return UIScreen.main.bounds.width * 0.6
  }
  let minCoverWidth: CGFloat = 40
  let maxVerticleMultiplier: CGFloat = 1
  let minVerticleMultiplier: CGFloat = 0.2
  let maxHorizontalMultiplier: CGFloat = 0.6
  let minHorizontalMultiplier: CGFloat = 0.1
  
  @IBOutlet weak var miniPlayerCoverImagePosition: UIView!
  @IBOutlet weak var largePlayerCoverImage: UIImageView!
  @IBOutlet weak var playerControllView: UIView!
  @IBOutlet weak var coverWidthConstraint: NSLayoutConstraint!
  @IBOutlet weak var coverHorizontalConstraint: NSLayoutConstraint!
  @IBOutlet weak var coverVerticleConstraint: NSLayoutConstraint!
  
  var minPlayerViewSize: CGFloat = 60
  var currentOrigin: CGPoint = CGPoint.zero
  var currentSize: CGFloat = 60
  
  @IBOutlet weak var miniPlayerBar: UIView!
  @IBOutlet weak var largePlayerView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    fromNib()
    setupLayer()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    fromNib()
    setupLayer()
  }
  
  func setupLayer() {
    self.backgroundColor = UIColor.clear
    miniPlayerBar.layer.cornerRadius = 10
    miniPlayerBar.clipsToBounds = true
    miniPlayerBar.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]

  }
  
  func resetCurrentRect(){
    currentSize = self.frame.size.height
    currentOrigin = self.frame.origin
  }
  override func onBegan() {
 resetCurrentRect()
  }
  override func onChanged(translation: CGFloat) {
    var newOrigin = currentOrigin
    var newSize = currentSize
    newOrigin.y += translation
    var factorScale = max(0, newOrigin.y/(UIScreen.main.bounds.height * 0.9))
    
    coverWidthConstraint.constant = lerp(factorScale, min: maxCoverWidth , max: minCoverWidth )
    coverVerticleConstraint = coverVerticleConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxVerticleMultiplier, max: minVerticleMultiplier))
    coverHorizontalConstraint = coverHorizontalConstraint.setMultiplier(multiplier: lerp(factorScale, min: maxHorizontalMultiplier, max: minHorizontalMultiplier))
    miniPlayerBar.alpha = factorScale * 3
    largePlayerView.layer.cornerRadius = 1 - 10 * factorScale * 3
    playerControllView.alpha = 1 - factorScale
    
    newSize -= translation
    self.frame.origin = newOrigin
  }
  override func onEnded(isClap: Bool) {
    if isClap {
      UIView.animate(withDuration: animationDuration, animations: {
        self.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height * 0.9)
        self.largePlayerView.layer.cornerRadius = 0
        self.miniPlayerBar.alpha = 1

        self.coverWidthConstraint.constant = self.minCoverWidth
        self.coverVerticleConstraint = self.coverVerticleConstraint.setMultiplier(multiplier: self.minVerticleMultiplier)
        self.coverHorizontalConstraint = self.coverHorizontalConstraint.setMultiplier(multiplier: self.minHorizontalMultiplier)
        self.layoutIfNeeded()

        
//         MARK: 原始版本
//        let largeCoverRect = self.convert(self.largePlayerCoverImage.frame, to: self)
//        let miniCoverRect = self.convert(self.miniPlayerCoverImagePosition.frame, to: self)
//        self.largePlayerCoverImage.transform = self.transformFromRect(from: largeCoverRect, toRect: miniCoverRect)

        self.delegate?.didClapPlayer()
      }, completion: { isCompleted in
        if isCompleted {
          self.resetCurrentRect()
        }
      })
    } else {
      UIView.animate(withDuration: animationDuration, animations: {
        self.frame.origin = CGPoint(x: 0, y: 0 )
        self.largePlayerView.layer.cornerRadius = 10
        self.miniPlayerBar.alpha = 0
        self.coverWidthConstraint.constant = self.maxCoverWidth
        self.coverVerticleConstraint = self.coverVerticleConstraint.setMultiplier(multiplier: self.maxVerticleMultiplier)
        self.coverHorizontalConstraint = self.coverHorizontalConstraint.setMultiplier(multiplier: self.maxHorizontalMultiplier)
        self.playerControllView.alpha = 1
        self.layoutIfNeeded()
//        MARK: 原始版本
//        self.largePlayerCoverImage.transform = CGAffineTransform.identity
        self.delegate?.didOpenPlayer()
      }, completion: { isCompleted in
        if isCompleted {
          self.resetCurrentRect()
        }
      })
    }
  }
  func transformFromRect(from source: CGRect, toRect destination: CGRect) -> CGAffineTransform {
    return CGAffineTransform.identity
      .translatedBy(x: destination.midX - source.midX, y: destination.midY - source.midY)
      .scaledBy(x: destination.width / source.width, y: destination.height / source.height)
  }
}
