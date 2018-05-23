//
//  EQMainScrollableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/13.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation

class EQMainScrollableViewController: EQScrollableViewController {
  var topItemSize = CGSize(width: 50, height: 50)
  let topIcon = [UIImage(named: "user")]
  var blurView: UIVisualEffectView!
  @IBOutlet weak var topScrollableViewBase: UIView!
  
  @IBOutlet weak var playerView: EQPlayerView!
  
  @IBAction func addEQAction(_: Any) {
    if let eqProjectViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQProjectViewController.self)) as? EQProjectViewController {
      eqProjectViewController.modalPresentationStyle = .overCurrentContext
      eqProjectViewController.modalTransitionStyle = .crossDissolve
      present(eqProjectViewController, animated: true, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    registerCollectionCell()
    setupDelegate()
    setupTopScrollableMainView()
    addBlurEffect()
    
    let userController = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")
    controllers.append(userController)
    cells.append("EQIconCollectionViewCell")
    data = ScrollableControllerDataModel(
      topCellId: cells,
      mainController: controllers
    )
    controllerInit()
  }
  
  func setupTopScrollableMainView(){
    topScrollableViewBase.layer.cornerRadius = 10
    topScrollableViewBase.clipsToBounds = true
  }
  
   func addBlurEffect(){
    let blurEffectView = UIVisualEffectView(effect: nil)
    blurEffectView.isUserInteractionEnabled = false
    blurEffectView.alpha = 0.8
    blurEffectView.frame = topScrollableViewBase.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    topScrollableViewBase.addSubview(blurEffectView)
    blurView = blurEffectView
  }
  

  func setupDelegate() {
    playerView.delegate = self
  }
  override func setupCell(cell: UICollectionViewCell, atIndex: Int) {
    if let iconCell = cell as? EQIconCollectionViewCell {
      iconCell.iconImageView.image = topIcon[atIndex]
    }
  }
  
  func registerCollectionCell() {
    let iconNib = UINib(nibName: "EQIconCollectionViewCell", bundle: nil)
    topCollectionView.register(iconNib, forCellWithReuseIdentifier: "EQIconCollectionViewCell")
  }
  
  override func customizeTopItemWhenScrolling(_ currentIndex: CGFloat = 0) {
    let cells = topCollectionView.visibleCells
    for cell in cells {
      if let iconCell = cell as? EQIconCollectionViewCell {
        let row = CGFloat((topCollectionView.indexPath(for: iconCell)?.row)!)
        iconCell.setupImageSize(size: topItemSize, currentIndex: currentIndex, cellRow: row)
      }
    }
  }
  
  override func setupCollectionLayout() {
    if let iconLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
      let spaceCount = visiableItemCount - 1
      iconLayout.itemSize = topItemSize
      // Center the first icon
      let insetEdge = UIScreen.main.bounds.width / 2 - (iconLayout.itemSize.width / 2)
      let spacing = (UIScreen.main.bounds.width - iconLayout.itemSize.width * visiableItemCount) / spaceCount
      iconLayout.minimumInteritemSpacing = 0
      iconLayout.minimumLineSpacing = spacing
      iconLayout.sectionInset = UIEdgeInsets(
        top: 0.0,
        left: insetEdge,
        bottom: 0.0,
        right: insetEdge
      )
      topPageWidth = UIScreen.main.bounds.width / spaceCount - topItemSize.width / 2
    }
  }
}

extension EQMainScrollableViewController: EQPlayerViewDelegate {
  func didClapPlayer() {
    self.topScrollableViewBase.transform = CGAffineTransform(scaleX: 1, y: 1)
    blurView.effect = nil
  }
  
  func didOpenPlayer() {
    self.topScrollableViewBase.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    blurView.effect = UIBlurEffect(style: .dark)
  }
}
