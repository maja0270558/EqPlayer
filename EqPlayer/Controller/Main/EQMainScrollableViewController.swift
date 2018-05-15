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

    @IBAction func addEQAction(_: Any) {
        if let playlistViewController = UIStoryboard.eqProjectStoryBoard().instantiateViewController(withIdentifier: String(describing: EQEditViewController.self)) as? EQEditViewController {
            playlistViewController.modalPresentationStyle = .overCurrentContext
            playlistViewController.modalTransitionStyle = .crossDissolve
            present(playlistViewController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        visiableItemCount = 3
        registerCollectionCell()

        for _ in 0 ... 3 {
            let userController = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")
            controllers.append(userController)
            cells.append("IconCollectionViewCell")
        }
        data = ScrollableControllerDataModel(
            topCellId: cells,
            mainController: controllers
        )
        controllerInit()
    }

    override func setupCell(cell _: UICollectionViewCell, atIndex: Int) {
    }

    func registerCollectionCell() {
        let iconNib = UINib(nibName: "IconCollectionViewCell", bundle: nil)
        topCollectionView.register(iconNib, forCellWithReuseIdentifier: "IconCollectionViewCell")
    }

    override func customizeTopItemWhenScrolling(_ currentIndex: CGFloat = 0) {
        let cells = topCollectionView.visibleCells
        for cell in cells {
            if let iconCell = cell as? IconCollectionViewCell {
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
