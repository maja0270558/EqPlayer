//
//  EQPlayerViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/22.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQPlayerViewController: UIViewController {
    @IBOutlet var backgroundView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.cornerRadius = 10
        backgroundView.clipsToBounds = true
    }
}
