//
//  EQMainViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol ScrollableController: class {
    var icon: UIImage { get set }
}
class EQMainViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var iconCollectionView: UICollectionView!
    var controllers = [Int]()
    var insetEdge: CGFloat = 0
    var pageIndex = 0
    var iconItemSize: CGSize {
        get {
            return CGSize(width: iconCollectionView.bounds.height, height: iconCollectionView.bounds.height)
        }
    }
    var currentIndex: CGFloat {
        get {
            return mainScrollView.contentOffset.x / mainScrollView.frame.size.width
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCell()
        setupCollectionLayout()
        setupScrollView()
        AppDelegate.shard?.spotifyManager.player?.playSpotifyURI("spotify:track:4OCIut15DsVwJrK8s02LJp", startingWith: 0, startingWithPosition: 0, callback: nil)
    }
    func setupCell() {
        let iconNib = UINib(nibName: "IconCollectionViewCell", bundle: nil)
        iconCollectionView.register(iconNib, forCellWithReuseIdentifier: "MultiTaskCell")
    }
    func setupScrollView() {
        controllers += [0, 0, 0, 0, 0, 0, 0, 0, 0]
        mainScrollView.contentSize = CGSize(width: mainScrollView.bounds.width * CGFloat(controllers.count), height: mainScrollView.bounds.height)
        var index: CGFloat = 0
        for scrollController in controllers {
            let containerView = UIView()
            containerView.frame.size = mainScrollView.bounds.size
            containerView.frame.origin = CGPoint(x: mainScrollView.bounds.width * index, y: 0)
            containerView.backgroundColor = UIColor.random()
            mainScrollView.addSubview(containerView)
            index += 1
        }
        mainScrollView.isPagingEnabled = true
    }
    func setupCollectionLayout() {
        if let iconLayout = iconCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            insetEdge = iconCollectionView.bounds.width/2 - (iconLayout.itemSize.width/2)
            iconLayout.itemSize = CGSize(width: iconCollectionView.bounds.size.height, height: iconCollectionView.bounds.size.height)
            let spacing = (iconCollectionView.bounds.width - iconCollectionView.bounds.size.height * 3) / 2
            iconLayout.minimumInteritemSpacing = 0
            iconLayout.minimumLineSpacing = spacing
            iconLayout.sectionInset = UIEdgeInsets(
                top: 0.0,
                left: insetEdge,
                bottom: 0.0,
                right: insetEdge
            )
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupIconSize()
    }
}

extension EQMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controllers.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiTaskCell", for: indexPath) as? IconCollectionViewCell else {
            fatalError("")
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageWidth: Float = Float(collectionView.bounds.width/2 - (iconItemSize.width/2))
        collectionView.setContentOffset(CGPoint(x: CGFloat(Float(indexPath.row) * pageWidth), y: 0), animated: true)

    }
}

extension EQMainViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let iconsCollectionViewFlowLayout = iconCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("icon")
        }
        let scrollViewDistanceBetweenItemsCenter = mainScrollView.bounds.width
        let iconsDistanceBetweenItemsCenter = iconsCollectionViewFlowLayout.minimumLineSpacing + iconsCollectionViewFlowLayout.itemSize.width
        let offsetFactor = scrollViewDistanceBetweenItemsCenter / iconsDistanceBetweenItemsCenter
        if scrollView === mainScrollView {
            let xOffset = scrollView.contentOffset.x - scrollView.frame.origin.x
            iconCollectionView.contentOffset.x = xOffset / offsetFactor
        } else if scrollView === iconCollectionView {
            let xOffset = scrollView.contentOffset.x - scrollView.frame.origin.x
            mainScrollView.contentOffset.x = xOffset * offsetFactor
        }
        setupIconSize(currentIndex)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === iconCollectionView {
            let pageWidth: Float = Float(scrollView.bounds.width/2 - (iconItemSize.width/2))
            let currentOffSet: Float = Float(scrollView.contentOffset.x)
            let targetOffSet: Float = Float(targetContentOffset.pointee.x)
            var newTargetOffset: Float = 0
            if targetOffSet > currentOffSet{
                newTargetOffset = ceilf(currentOffSet / pageWidth) * pageWidth
            } else {
                newTargetOffset = floorf(currentOffSet / pageWidth) * pageWidth
            }
            if newTargetOffset < 0 {
                newTargetOffset = 0
            } else if newTargetOffset > Float(scrollView.contentSize.width) {
                newTargetOffset = Float(scrollView.contentSize.width)
            }
            targetContentOffset.pointee.x = CGFloat(currentOffSet)
            scrollView.setContentOffset(CGPoint(x: CGFloat(newTargetOffset), y: 0), animated: true)
        }
    }
   
    func setupIconSize(_ currentIndex: CGFloat = 0) {
        let cells = iconCollectionView.visibleCells
        for cell in cells {
            if let iconCell = cell as? IconCollectionViewCell {
                let row = CGFloat((iconCollectionView.indexPath(for: iconCell)?.row)!)
                iconCell.setupImageSize(size: iconItemSize, currentIndex: currentIndex, cellRow: row)
            }
        }
    }
}
