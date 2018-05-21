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
  
  func isLight() -> Bool
  {
    guard let components = self.cgColor.components else {
      return true
    }
    let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
    
    if brightness < 0.7
    {
      return false
    }
    else
    {
      return true
    }
  }
  func isLightColor() -> Bool
  {
    var white: CGFloat = 0.0
    self.getWhite(&white, alpha: nil)
    
    var isLight = false
    
    if white >= 0.3
    {
      isLight = true
    }
    return isLight
  }
  
  func lighter(by percentage:CGFloat=30.0) -> UIColor? {
    return self.adjust(by: abs(percentage) )
  }
  
  func darker(by percentage:CGFloat=30.0) -> UIColor? {
    return self.adjust(by: -1 * abs(percentage) )
  }
  
  func adjust(by percentage:CGFloat=30.0) -> UIColor? {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    if(self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)){
      return UIColor(red: min(red + percentage/100, 1.0),
                     green: min(green + percentage/100, 1.0),
                     blue: min(blue + percentage/100, 1.0),
                     alpha: alpha)
    }else{
      return nil
    }
  }
  
}

extension UIImage {
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
