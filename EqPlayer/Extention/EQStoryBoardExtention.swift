//
//  EQStoryBoardExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension UIStoryboard {
    static func loginStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }

    static func mainStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }

    static func eqProjectStoryBoard() -> UIStoryboard {
        return UIStoryboard(name: "EQProject", bundle: nil)
    }
  
    static func loadingBoard() -> UIStoryboard {
      return UIStoryboard(name: "Loading", bundle: nil)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

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

extension UIImageView {
    func addShadow(offset: CGSize = CGSize(width: 0, height: 0),
                   radius: CGFloat = 10,
                   opacity: Float = 1,
                   color: CGColor = UIColor.black.cgColor) {
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color
        layer.masksToBounds = false
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [kCIContextWorkingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }

    func getPixelColor(_ point: CGPoint) -> UIColor {
        let cgImage: CGImage = self.cgImage!
        guard let pixelData = CGDataProvider(data: (cgImage.dataProvider?.data)!)?.data else {
            return UIColor.clear
        }
        let data = CFDataGetBytePtr(pixelData)!
        let xPoint = Int(point.x)
        let yPoint = Int(point.y)
        let index = Int(size.width) * yPoint + xPoint
        let expectedLengthA = Int(size.width * size.height)
        let expectedLengthRGB = 3 * expectedLengthA
        let expectedLengthRGBA = 4 * expectedLengthA
        let numBytes = CFDataGetLength(pixelData)
        switch numBytes {
        case expectedLengthA:
            return UIColor(red: 0, green: 0, blue: 0, alpha: CGFloat(data[index]) / 255.0)
        case expectedLengthRGB:
            return UIColor(red: CGFloat(data[3 * index]) / 255.0, green: CGFloat(data[3 * index + 1]) / 255.0, blue: CGFloat(data[3 * index + 2]) / 255.0, alpha: 1.0)
        case expectedLengthRGBA:
            return UIColor(red: CGFloat(data[4 * index]) / 255.0, green: CGFloat(data[4 * index + 1]) / 255.0, blue: CGFloat(data[4 * index + 2]) / 255.0, alpha: CGFloat(data[4 * index + 3]) / 255.0)
        default:
            return UIColor.clear
        }
    }

    class func imageWithColor(color: UIColor) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    class func roundedImage(image: UIImage, cornerRadius: Int) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        UIGraphicsBeginImageContextWithOptions(image.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: CGFloat(cornerRadius)
        ).addClip()
        image.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}
