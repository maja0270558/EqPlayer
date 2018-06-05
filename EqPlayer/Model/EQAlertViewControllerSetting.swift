//
//  EQAlertViewControllerSetting.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/30.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
import PopupDialog
class EQAlertViewControllerSetting {
    static func setDarkMode() {
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor = .white
        pv.messageFont = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)

        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red: 0.23, green: 0.23, blue: 0.27, alpha: 1.00)
        pcv.cornerRadius = 2
        pcv.shadowEnabled = true
        pcv.shadowColor = .black

        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled = true
        ov.blurRadius = 30
        ov.liveBlurEnabled = true
        ov.opacity = 0.3
        ov.color = .black
        ov.isUserInteractionEnabled = false

        let db = DefaultButton.appearance()
        db.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor = .white
        db.buttonColor = UIColor(red: 0.25, green: 0.25, blue: 0.29, alpha: 1.00)
        db.separatorColor = UIColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1.00)

        let cb = CancelButton.appearance()
        cb.titleFont = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor = UIColor(red: 0.25, green: 0.25, blue: 0.29, alpha: 1.00)
        cb.separatorColor = UIColor(red: 0.20, green: 0.20, blue: 0.25, alpha: 1.00)
    }
}
