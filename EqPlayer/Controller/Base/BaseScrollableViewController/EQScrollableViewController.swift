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

protocol EQScrollableViewControllerProtocol {
    func setupCell(cell: UICollectionViewCell, atIndex: Int)
    func setupCollectionLayout()
    func customizeTopItemWhenScrolling(_ currentIndex: CGFloat)
}

class EQScrollableViewController: EQPannableViewController, EQScrollableViewControllerProtocol {
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
    var visiableItemCount: CGFloat = 3
    var data = ScrollableControllerDataModel()

    var controllers = [UIViewController]()
    var cells = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        topCollectionView.delegate = self
        topCollectionView.dataSource = self
        mainScrollView.delegate = self
    }

    override func viewDidAppear(_: Bool) {
        customizeTopItemWhenScrolling()
    }

    func controllerInit() {
        setupCollectionLayout()
        setupScrollView()
    }

    func setupScrollView() {
        var index: CGFloat = 0
        var previousController: UIViewController?
        for controller in data.mainController {
            addChildViewController(controller)
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

    func goTo(pageAt: Int) {
        mainScrollView.setContentOffset(CGPoint(x: CGFloat(pageAt) * topPageWidth, y: 0), animated: true)
    }
}

extension EQScrollableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return data.mainController.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: data.topCellId[indexPath.row], for: indexPath)
        setupCell(cell: cell, atIndex: indexPath.row)
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

    @objc func setupCell(cell _: UICollectionViewCell, atIndex _: Int) {
    }

    @objc func customizeTopItemWhenScrolling(_: CGFloat = 0) {
    }

    @objc func setupCollectionLayout() {
    }
}
