//
//  EQUserInfoView.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/5.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQUserInfoView: UIView {
    @IBOutlet var userImage: EQCircleImage!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var userName: UILabel!

    private func checkCameraButtonDismiss() {
        if EQUserManager.shard.userStatus == .guest {
            cameraButton.isHidden = true
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
        checkCameraButtonDismiss()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
        checkCameraButtonDismiss()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if cameraButton.frame.contains(point) {
            return hitView
        } else {
            return nil
        }
    }
}
