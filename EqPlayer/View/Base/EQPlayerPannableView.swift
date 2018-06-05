//
//  EQPlayerPannableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//
import Foundation
import UIKit

class EQPlayerPannableView: UIView {
    public var minimumVelocityToHide = 1500 as CGFloat
    public var minimumScreenRatioToHide = 0.5 as CGFloat
    public var animationDuration = 0.2 as TimeInterval
    private var canPan = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        addGesture()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addGesture()
    }

    func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(panGesture)
    }

    func slideViewVerticallyTo(_ yPosition: CGFloat) {
        frame.origin = CGPoint(x: 0, y: yPosition)
    }

    func setCanPanToDismiss(_ canPan: Bool) {
        self.canPan = canPan
    }

    func onBegan() {
    }

    func onChanged(translation _: CGFloat) {
    }

    func onEnded(isClap _: Bool) {
    }

    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        if canPan {
            switch panGesture.state {
            case .began:
                onBegan()
            case .changed:
                let translation = panGesture.translation(in: self)
                onChanged(translation: translation.y)
            case .ended:
                let translation = panGesture.translation(in: self)
                let velocity = panGesture.velocity(in: self)
                let isClap = (translation.y > frame.size.height * minimumScreenRatioToHide) ||
                    (velocity.y > minimumVelocityToHide)
                onEnded(isClap: isClap)
            default:
                break
            }
        }
    }
}
