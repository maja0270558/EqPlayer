//
//  EQLoadingViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/28.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class EQLoadingViewController: UIViewController {

  @IBOutlet weak var loadingProgress: NVActivityIndicatorView!
  override func viewDidLoad() {
        super.viewDidLoad()
        loadingProgress.startAnimating()
    }
}
