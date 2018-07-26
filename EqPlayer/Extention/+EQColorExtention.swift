//
//  +EQColorExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/6/5.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red: .random(),
                       green: .random(),
                       blue: .random(),
                       alpha: 1.0)
    }

    func isLight() -> Bool {
        guard let components = self.cgColor.components else {
            return true
        }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000

        if brightness < 0.7 {
            return false
        } else {
            return true
        }
    }

    func isLightColor() -> Bool {
        var white: CGFloat = 0.0
        getWhite(&white, alpha: nil)

        var isLight = false

        if white >= 0.3 {
            isLight = true
        }
        return isLight
    }

    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: abs(percentage))
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return adjust(by: -1 * abs(percentage))
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: min(red + percentage / 100, 1.0),
                           green: min(green + percentage / 100, 1.0),
                           blue: min(blue + percentage / 100, 1.0),
                           alpha: alpha)
        } else {
            return nil
        }
    }
}
