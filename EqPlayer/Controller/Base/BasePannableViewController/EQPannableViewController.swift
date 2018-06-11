//
//  EQPannableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/18.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import UIKit

class EQPannableViewController: UIViewController {
    public var minimumVelocityToHide = 1500 as CGFloat
    public var minimumScreenRatioToHide = 0.5 as CGFloat
    public var animationDuration = 0.2 as TimeInterval
    private var canPan = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        view.addGestureRecognizer(panGesture)
    }

    func slideViewVerticallyTo(_ yPosition: CGFloat) {
        view.alpha = 1 - (yPosition / view.bounds.height)
        view.frame.origin = CGPoint(x: 0, y: yPosition)
    }

    func setCanPanToDismiss(_ canPan: Bool) {
        self.canPan = canPan
    }

    func onDismiss() {
    }

    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        if canPan {
            switch panGesture.state {
            case .began, .changed:
                let translation = panGesture.translation(in: view)
                let yPosition = max(0, translation.y)
                slideViewVerticallyTo(yPosition)
            case .ended:
                let translation = panGesture.translation(in: view)
                let velocity = panGesture.velocity(in: view)
                let closing = (translation.y > view.frame.size.height * minimumScreenRatioToHide) ||
                    (velocity.y > minimumVelocityToHide)

                if closing {
                    UIView.animate(withDuration: animationDuration, animations: {
                        self.view.alpha = 0
                        self.slideViewVerticallyTo(self.view.frame.size.height)
                    }, completion: { isCompleted in
                        if isCompleted {
                            self.onDismiss()
                        }
                    })
                } else {
                    backToAppear()
                }
            default:
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(0)
                })
            }
        }
    }

    func backToAppear() {
        UIView.animate(withDuration: animationDuration, animations: {
            self.slideViewVerticallyTo(0)
            self.view.alpha = 1
        })
    }

    override init(nibName _: String?, bundle _: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
}
