//
//  EQCustomUITextField.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQCustomUITextField: UITextField {

    func setupTextField (_ textField: UITextField) {
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .default
        textField.returnKeyType = .done
        textField.clearButtonMode = .whileEditing
        textField.contentVerticalAlignment = .center
        textField.layer.cornerRadius = textField.bounds.height/2
        textField.clipsToBounds = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        setupTextField(self)
    }

}
