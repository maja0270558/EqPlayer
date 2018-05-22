//
//  EQSaveProjectCell.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/9.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
import Charts
import UIImageColors

class EQSaveProjectCell: UITableViewCell {
  @IBOutlet weak var playlistCover: EQCircleImage!
  @IBOutlet weak var cellEQChartView: LineChartView!
  @IBOutlet weak var projectTitleLabel: UILabel!
  @IBOutlet weak var trackCountLabel: UILabel!
  @IBOutlet weak var cellIndicator: UIActivityIndicatorView!

  var discImageLarge: UIImageView! {
    return viewWithTag(1) as? UIImageView
  }
  let dispatchGroup = DispatchGroup()

  @IBAction func moreOptionButton(_ sender: UIButton) {
    
  }
  
  func setDiscsImage(imageURLs: [String], completion: @escaping () -> Void = { return } ) {
    //1  up
    var clampedURLsCount = (imageURLs.count >= 3) ? 3 : imageURLs.count
    resetDiscImage()
    for index in stride(from: 1, through: clampedURLsCount, by: 1) {
      setDiscImage(index: index, url: imageURLs[index-1])
    }
    dispatchGroup.notify(queue: .main) {
      completion()
    }
  }
  
  func resetDiscImage() {
    for index in stride(from: 1, through: 3, by: 1) {
      if let disc = viewWithTag(index) as? UIImageView{
        disc.image = UIImage(named: "vinyl")
        disc.isHidden = true
      }
    }
  }
  
  private func setDiscImage(index: Int, url: String){
    if let disc = viewWithTag(index) as? UIImageView, let imageURL = URL(string: url) {
      dispatchGroup.enter()
      disc.sd_setImage(with: imageURL) { (_, _, _, _) in
        disc.isHidden = false
        self.dispatchGroup.leave()
      }
    }
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        cellEQChartView.configStyle(.cell)
        cellEQChartView.setChart(15, color: UIColor.green, style: .cell)
        // Initialization code
    }
}
