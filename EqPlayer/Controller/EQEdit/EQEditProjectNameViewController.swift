//
//  EQEditProjectNameViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol EQEditProjectNameViewControllerDelegate: class {
    func saveOnClick(projectName: String)
}
class EQEditProjectNameViewController: UIViewController {
    weak var delegate: EQEditProjectNameViewControllerDelegate?
    var originalProjectName: String = ""
    @IBOutlet weak var projectNameTextField: EQCustomUITextField!
    @IBOutlet weak var saveButton: EQCustomButton!
    @IBAction func saveAction(_ sender: EQCustomButton) {
        delegate?.saveOnClick(projectName: projectNameTextField.text!)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        projectNameTextField.delegate = self
        projectNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        projectNameTextField.becomeFirstResponder()
        projectNameTextField.text = originalProjectName
        // Do any additional setup after loading the view.
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text?.isEmpty)! {
            saveButton.isEnabled = false
            saveButton.alpha = 0.5
        } else {
            saveButton.isEnabled = true
            saveButton.alpha = 1
        }
    }
}
extension EQEditProjectNameViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}
