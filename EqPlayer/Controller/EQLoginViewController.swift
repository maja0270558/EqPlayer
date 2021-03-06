//
//  EQLoginViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import NVActivityIndicatorView
import UIKit
class EQLoginViewController: UIViewController {
    weak var appDelegate = UIApplication.shared.delegate

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var loginProgress: NVActivityIndicatorView!
    @IBAction func guestLogin(_: EQCustomButton) {
        AppDelegate.shard?.switchToMainStoryBoard()
    }

    @IBAction func loginAction(_: UIButton) {
        if let delegate = appDelegate as? AppDelegate {
            delegate.spotifyManager.login()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
}
