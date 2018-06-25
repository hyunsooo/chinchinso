//
//  PinterestLayout.swift
//  chinchinso
//
//  Created by hyunsu han on 2017. 12. 7..
//  Copyright © 2017년 hyunsu han. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForDateItemAtIndexPath indexPath:IndexPath) -> CGFloat
}
class PinterestLayout: UICollectionViewLayout {
    
    weak var delegate: PinterestLayoutDelegate!
    
    var columns = 2
    var padding: CGFloat = 5
    
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    private var cache = [UICollectionViewLayoutAttributes]()
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else { return }
        let columnWidth = contentWidth / CGFloat(columns)
        var xOffSet = [CGFloat]()
        for column in 0 ..< columns {
            xOffSet.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffSet = [CGFloat](repeating: 0, count: columns)
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate.collectionView(collectionView, heightForDateItemAtIndexPath: indexPath)
            let height = padding * 2 + photoHeight
            let frame = CGRect(x: xOffSet[column], y: yOffSet[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: padding, dy: padding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffSet[column] = yOffSet[column] + height
            
            column = column < (columns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}
