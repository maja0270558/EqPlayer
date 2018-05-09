//
//  EQCollectionViewFlowLayout.swift
//  EqPlayer
//
//  Created by 大容 林 on 2018/5/7.
//  Copyright © 2018年 Django. All rights reserved.
//

import Foundation
class EQCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity _: CGPoint) -> CGPoint {
        var offsetAdjustment = MAXFLOAT
        let horizontalOffset = proposedContentOffset.x + (collectionView!.bounds.size.width - itemSize.width) / 2.0
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView!.bounds.size.width, height: collectionView!.bounds.size.height)
        let array = super.layoutAttributesForElements(in: targetRect)

        for layoutAttributes in array! {
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(offsetAdjustment) {
                offsetAdjustment = Float(itemOffset - horizontalOffset)
            }
        }

        let offsetX = Float(proposedContentOffset.x) + offsetAdjustment
        return CGPoint(x: CGFloat(offsetX), y: proposedContentOffset.y)
    }
}
