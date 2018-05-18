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
        // Listen for pan gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        self.view.addGestureRecognizer(panGesture)
    }
    
    func slideViewVerticallyTo(_ yPosition: CGFloat) {
        self.view.alpha = 1 - (yPosition/self.view.bounds.height)
        self.view.frame.origin = CGPoint(x: 0, y: yPosition)
    }
    
    func setCanPanToDismiss(_ canPan :Bool){
        self.canPan = canPan
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        if canPan {
            switch panGesture.state {
            case .began, .changed:
                // If pan started or is ongoing then
                // slide the view to follow the finger
                let translation = panGesture.translation(in: view)
                let yPosition = max(0, translation.y)
                self.slideViewVerticallyTo(yPosition)
                break
            case .ended:
                // If pan ended, decide it we should close or reset the view
                // based on the final position and the speed of the gesture
                let translation = panGesture.translation(in: view)
                let velocity = panGesture.velocity(in: view)
                let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) ||
                    (velocity.y > minimumVelocityToHide)
                
                if closing {
                    UIView.animate(withDuration: animationDuration, animations: {
                        // If closing, animate to the bottom of the view
                        self.view.alpha = 0
                        self.slideViewVerticallyTo(self.view.frame.size.height)
                    }, completion: { (isCompleted) in
                        if isCompleted {
                            // Dismiss the view when it dissapeared
                            self.dismiss(animated: false, completion: nil)
                        }
                    })
                } else {
                    // If not closing, reset the view to the top
                    UIView.animate(withDuration: animationDuration, animations: {
                        self.slideViewVerticallyTo(0)
                        self.view.alpha = 1
                    })
                }
                break
            default:
                // If gesture state is undefined, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    self.slideViewVerticallyTo(0)
                })
                break
            }
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)   {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
}
