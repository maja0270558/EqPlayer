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

protocol EQSaveProjectCellDelegate : class {
  func didClickMoreOptionButton(indexPath: IndexPath)
}

class EQSaveProjectCell: UITableViewCell {
  weak var delegate: EQSaveProjectCellDelegate?
  @IBOutlet weak var playlistCover: EQCircleImage!
  @IBOutlet weak var cellEQChartView: LineChartView!
  @IBOutlet weak var projectTitleLabel: UILabel!
  @IBOutlet weak var trackCountLabel: UILabel!
  @IBOutlet weak var cellIndicator: UIActivityIndicatorView!
  @IBOutlet weak var playbutton: UIButton!
  var cellIndexPath: IndexPath?
  
  var discImageLarge: UIImageView! {
    return viewWithTag(1) as? UIImageView
  }
  @IBAction func moreOptionButton(_ sender: UIButton) {
    delegate?.didClickMoreOptionButton(indexPath: cellIndexPath!)
  }
  
  @IBAction func playPlaylistAction(_ sender: UIButton) {
    
    
  }
  func setDiscsImage(imageURLs: [String], completion: @escaping () -> Void = { return } ) {
    var clampedURLsCount = (imageURLs.count >= 3) ? 3 : imageURLs.count
    resetDiscImage()
    if  imageURLs.count < 0 {
      completion()
      return
    }
    if let disc = viewWithTag(1) as? UIImageView {
      disc.sd_setImage(with: URL(string: imageURLs[0])) { (_, _, _, _) in
        disc.isHidden = false
        completion()
      }
    }
    for index in stride(from: 2, through: clampedURLsCount, by: 1) {
      setDiscImage(index: index, url: imageURLs[index-1])
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
      disc.sd_setImage(with: imageURL) { (_, _, _, _) in
        disc.isHidden = false
      }
    }
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        cellEQChartView.configStyle(.cell)
        cellEQChartView.setChart(15, color: UIColor.green, style: .cell)
        playbutton.layer.shadowOffset = CGSize(width: 1, height: 1)
        playbutton.layer.shadowRadius = 5
        playbutton.layer.shadowOpacity = 1
        playbutton.layer.shadowColor = UIColor.black.cgColor
    }
}
