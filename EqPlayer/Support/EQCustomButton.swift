//
//  EQCustomButton.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQCustomButton: UIButton {

    func setupButton(_ button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.clipsToBounds = true
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.white.cgColor
        button.tintColor = UIColor.white
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupButton(self)
    }
}
