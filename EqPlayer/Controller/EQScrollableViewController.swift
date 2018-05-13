//
//  EQScrollableViewController.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/11.
//  Copyright © 2018年 Django. All rights reserved.
//

import UIKit
enum EQScrollableViewID: Int {
    case topCollectionView = 100
    case mainScrollView = 101
}
struct ScrollableControllerDataModel {
    var topCellId: [String] = [String]()
    var mainController: [UIViewController] = [UIViewController]()
}
class EQScrollableViewController: UIViewController {
    var mainScrollView: UIScrollView! {
        return view.viewWithTag(EQScrollableViewID.mainScrollView.rawValue) as? UIScrollView
    }
    var topCollectionView: UICollectionView! {
        return view.viewWithTag(EQScrollableViewID.topCollectionView.rawValue) as? UICollectionView
    }
    var currentIndex: CGFloat {
        return mainScrollView.contentOffset.x / mainScrollView.frame.size.width
    }
    var topPageWidth: CGFloat = 0
    var data = ScrollableControllerDataModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        //set page width
        setupCollectionLayout()
        setupScrollView()
    }

    override func viewDidAppear(_: Bool) {
        customizeTopItemWhenScrolling()
    }

    func setupScrollView() {
        var index: CGFloat = 0
        var previousController: UIViewController?
        for controller in data.mainController {
            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            mainScrollView.addSubview(containerView)
            if let preController = previousController {
                if Int(index) >= data.mainController.count - 1 {
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
        if let iconLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            iconLayout.itemSize = CGSize(width: topCollectionView.bounds.size.height, height: topCollectionView.bounds.size.height)
            let insetEdge = UIScreen.main.bounds.width / 2 - (iconLayout.itemSize.width / 2)
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

}

extension EQScrollableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return data.mainController.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.topCellId[indexPath.row], for: indexPath)
        setupCell(cell: cell)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) * topPageWidth, y: 0), animated: true)
    }

}

extension EQScrollableViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let iconsCollectionViewFlowLayout = topCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("icon")
        }

        let scrollViewDistanceBetweenItemsCenter = mainScrollView.bounds.width

        let iconsDistanceBetweenItemsCenter = iconsCollectionViewFlowLayout.minimumLineSpacing + iconsCollectionViewFlowLayout.itemSize.width

        let offsetFactor = scrollViewDistanceBetweenItemsCenter / iconsDistanceBetweenItemsCenter

        if scrollView === mainScrollView {
            let xOffset = scrollView.contentOffset.x - scrollView.frame.origin.x

            topCollectionView.contentOffset.x = xOffset / offsetFactor

        } else if scrollView === topCollectionView {
            let xOffset = scrollView.contentOffset.x - scrollView.frame.origin.x

            mainScrollView.contentOffset.x = xOffset * offsetFactor
        }
        customizeTopItemWhenScrolling(currentIndex)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity _: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === topCollectionView {
            let currentOffSet: Float = Float(scrollView.contentOffset.x)
            let targetOffSet: Float = Float(targetContentOffset.pointee.x)
            var newTargetOffset: Float = 0
            if targetOffSet > currentOffSet {
                newTargetOffset = ceilf(currentOffSet / Float(topPageWidth)) * Float(topPageWidth)

            } else {
                newTargetOffset = floorf(currentOffSet / Float(topPageWidth)) * Float(topPageWidth)
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

    func setupCell(cell: UICollectionViewCell) {

    }

    func customizeTopItemWhenScrolling(_ currentIndex: CGFloat = 0) {

    }
}
