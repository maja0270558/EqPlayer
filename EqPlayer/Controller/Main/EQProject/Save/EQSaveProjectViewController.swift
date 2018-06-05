//
//  EQSaveProjectViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/17.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol EQSaveProjectViewControllerDelegate: class {
    func didClickSaveButton(projectName: String, description: String, isPost: Bool)
}

class EQSaveProjectViewController: UIViewController {
    @IBOutlet var projectNameTextField: EQCustomUITextField!
    @IBOutlet var postDescriptionTextField: EQCustomUITextField!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var saveButton: EQCustomButton!

    weak var delegate: EQSaveProjectViewControllerDelegate?
    var originalProjectName: String = ""
    var controllerIsUseToPost: Bool = false
    @IBAction func saveAction(_: EQCustomButton) {
        dismiss(animated: true) {
            self.delegate?.didClickSaveButton(projectName: self.projectNameTextField.text!, description: self.postDescriptionTextField.text!, isPost: self.controllerIsUseToPost)
        }
    }

    @IBAction func cancelAction(_: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProjectNameTextField()
        setupStyle(isPost: controllerIsUseToPost)
    }

    func setupProjectNameTextField() {
        projectNameTextField.delegate = self
        projectNameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        projectNameTextField.text = originalProjectName
    }

    func setupStyle(isPost: Bool) {
        if !isPost {
            descriptionLabel.isHidden = true
            postDescriptionTextField.isHidden = true
            saveButton.setTitle("儲存", for: .normal)
            projectNameTextField.becomeFirstResponder()

        } else {
            projectNameTextField.isEnabled = false
            projectNameTextField.alpha = 0.5
            postDescriptionTextField.becomeFirstResponder()
            saveButton.setTitle("發布", for: .normal)
        }
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

extension EQSaveProjectViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}
