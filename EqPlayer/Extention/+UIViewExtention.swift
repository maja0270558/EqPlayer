//
//  NibLoadable.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
extension UIView {
    @discardableResult
    func fromNib<T: UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {
            return nil
        }
        addSubview(contentView)
        self.backgroundColor = UIColor.clear
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        return contentView
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
