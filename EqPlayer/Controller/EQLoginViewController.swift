//
//  EQLoginViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQLoginViewController: UIViewController {
   weak var appDelegate = UIApplication.shared.delegate

    @IBOutlet weak var loginButton: UIButton!

    @IBAction func loginAction(_ sender: UIButton) {
        if let delegate = appDelegate as? AppDelegate {
            delegate.spotifyManager.login()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
