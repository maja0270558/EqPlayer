//
//  EQNotifycationCenterManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQNotifycationCenterManager {
    static func post(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }

    static func addObserver(observer: AnyObject, selector: Selector, notification: Notification.Name) {
        NotificationCenter.default
            .addObserver(observer, selector: selector, name: notification, object: nil)
    }
}

extension Notification.Name {
    static let eqProjectTrackModifyNotification = Notification.Name("eqProjectTrackModifyNotification")
}
