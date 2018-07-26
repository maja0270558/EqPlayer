//
//  EQImageExtention.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        var newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

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
