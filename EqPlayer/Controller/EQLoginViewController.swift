//
//  EQLoginViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class EQLoginViewController: UIViewController {
    weak var appDelegate = UIApplication.shared.delegate

    @IBOutlet var loginButton: UIButton!
    @IBOutlet weak var loginProgress: NVActivityIndicatorView!
  
    @IBAction func loginAction(_: UIButton) {
        if let delegate = appDelegate as? AppDelegate {
            loginProgress.startAnimating()
            delegate.spotifyManager.login()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
}
