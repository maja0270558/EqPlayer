//
//  EQMainViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQMainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shard?.spotifyManager.player?.playSpotifyURI("spotify:track:4OCIut15DsVwJrK8s02LJp", startingWith: 0, startingWithPosition: 0, callback: nil)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
