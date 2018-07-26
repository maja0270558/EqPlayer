//
//  EQNotifycationCenterManager.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQNotifycationCenterManager: NSObject {
    static func post(name: Notification.Name) {
        NotificationCenter.default.post(name: name, object: nil)
    }

    static func addObserver(observer: AnyObject,
                            selector: Selector,
                            notification: Notification.Name) {
        NotificationCenter.default
            .addObserver(observer, selector: selector, name: notification, object: nil)
    }

    static func removeObseve(observer: AnyObject,
                             name: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: name, object: nil)
    }
}

extension Notification.Name {
    static let eqProjectTrackModifyNotification = Notification.Name("eqProjectTrackModifyNotification")
    static let eqProjectSave = Notification.Name("eqProjectSave")
    static let eqProjectDidChangeUnsave = Notification.Name("eqProjectDidChangeUnsave")
    static let eqProjectAccidentallyClose = Notification.Name("eqProjectAccidentallyClose")
    static let eqProjectDelete = Notification.Name("eqProjectDelete")
    static let eqProjectPlayPreviewTrack = Notification.Name("eqProjectPlayPreviewTrack")
}

extension NSNotification {
    @objc static var eqProjectTrackModifyNotification: NSString {
        return "eqProjectTrackModifyNotification"
    }
    @objc static var eqProjectSave: NSString {
        return "eqProjectSave"
    }
    @objc static var eqProjectDidChangeUnsave: NSString {
        return "eqProjectDidChangeUnsave"
    }
    @objc static var eqProjectAccidentallyClose: NSString {
        return "eqProjectAccidentallyClose"
    }
    @objc static var eqProjectDelete: NSString {
        return "eqProjectDelete"
    }
    @objc static var eqProjectPlayPreviewTrack: NSString {
        return "eqProjectPlayPreviewTrack"
    }
}
