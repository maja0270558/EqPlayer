//
//  EQCustomSearchBar.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/10.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit

class EQCustomSearchBar: UISearchBar {
    override func awakeFromNib() {
        self.setBackgroundImage(UIImage.imageWithColor(color: UIColor.clear), for: UIBarPosition(rawValue: 0)!, barMetrics: .default)
        let searchBarBackground = UIImage.roundedImage(image: UIImage.imageWithColor(color: UIColor.black, size: CGSize(width: 28, height: 28)),cornerRadius: 2)
        self.setSearchFieldBackgroundImage(searchBarBackground, for: .normal)
        self.searchTextPositionAdjustment = UIOffset(horizontal: 8    , vertical: 0)
        let textFieldInsideSearchBar = self.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor(red: 201/255, green: 201/255, blue: 201/255, alpha: 1)
    }
  
}
