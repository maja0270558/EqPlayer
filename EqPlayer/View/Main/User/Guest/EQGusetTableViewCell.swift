//
//  EQGusetTableViewCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/29.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQGusetTableViewCell: UITableViewCell {
  var backToLogin: () -> Void = {
    return
  }
  @IBAction func backToLoginAction(_ sender: EQCustomButton) {
    backToLogin()
  }
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
