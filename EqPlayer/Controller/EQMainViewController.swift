//
//  EQMainViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
protocol ScrollableController: class {
    var icon: UIImage? { get set }
}

class EQMainViewController: UIViewController {
    @IBOutlet var mainScrollView: UIScrollView!

    @IBOutlet var iconCollectionView: UICollectionView!

    var controllers = [UIViewController]()

    var insetEdge: CGFloat = 0

    var pageIndex = 0

    var iconItemSize: CGSize {
        return CGSize(width: iconCollectionView.bounds.height, height: iconCollectionView.bounds.height)
    }

    var currentIndex: CGFloat {
        return mainScrollView.contentOffset.x / mainScrollView.frame.size.width
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
        let userController = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")
        let userController2 = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")
        let userController3 = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")
        let userController4 = UIStoryboard.mainStoryBoard().instantiateViewController(withIdentifier: "EQUserTableViewController")

        controllers.append(userController)
        controllers.append(userController2)
        controllers.append(userController3)
        controllers.append(userController4)

        var index: CGFloat = 0
        var previousController: UIViewController?
        for controller in controllers {
            let containerView = UIView()
            containerView.backgroundColor = UIColor.random()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            mainScrollView.addSubview(containerView)
            if let preController = previousController {
                if Int(index) >= controllers.count - 1 {
                    NSLayoutConstraint.activate([
                        containerView.leadingAnchor.constraint(equalTo: preController.view.trailingAnchor),
                        containerView.trailingAnchor.constraint(equalTo: mainScrollView.trailingAnchor)
                    ])
                } else {
                    NSLayoutConstraint.activate([
                        containerView.leadingAnchor.constraint(equalTo: preController.view.trailingAnchor)
                    ])
                }
                NSLayoutConstraint.activate([
                    containerView.heightAnchor.constraint(equalTo: preController.view.heightAnchor),
                    containerView.widthAnchor.constraint(equalTo: preController.view.widthAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    containerView.leadingAnchor.constraint(equalTo: mainScrollView.leadingAnchor),
                    containerView.heightAnchor.constraint(equalTo: mainScrollView.heightAnchor),
                    containerView.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
                ])
            }
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: mainScrollView.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: mainScrollView.bottomAnchor)
            ])
            previousController = controller
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(controller.view)
            NSLayoutConstraint.activate([
                controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                controller.view.topAnchor.constraint(equalTo: containerView.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                controller.view.widthAnchor.constraint(equalTo: mainScrollView.widthAnchor)
            ])
            controller.didMove(toParentViewController: self)
            index += 1
        }

        mainScrollView.isPagingEnabled = true
    }

    func setupCollectionLayout() {
        if let iconLayout = iconCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            iconLayout.itemSize = CGSize(width: iconCollectionView.bounds.size.height, height: iconCollectionView.bounds.size.height)
            insetEdge = UIScreen.main.bounds.width / 2 - (iconLayout.itemSize.width / 2)
            let spacing = (UIScreen.main.bounds.width - iconLayout.itemSize.width * 3) / 2

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

    override func viewDidAppear(_: Bool) {
        setupIconSize()
    }
}

extension EQMainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return controllers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultiTaskCell", for: indexPath) as? IconCollectionViewCell else {
            fatalError("")
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pageWidth: Float = Float(collectionView.bounds.width / 2 - (iconItemSize.width / 2))

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

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === iconCollectionView {
            let pageWidth: Float = Float(scrollView.bounds.width / 2 - (iconItemSize.width / 2))

            let currentOffSet: Float = Float(scrollView.contentOffset.x)

            let targetOffSet: Float = Float(targetContentOffset.pointee.x)

            var newTargetOffset: Float = 0

            if targetOffSet > currentOffSet {
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
