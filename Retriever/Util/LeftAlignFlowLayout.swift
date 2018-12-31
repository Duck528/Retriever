//
//  LeftAlignFlowLayout.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit

class LeftAlignFlowLayout: NSCollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [NSCollectionViewLayoutAttributes] {
        let attributes = super.layoutAttributesForElements(in: rect)
        var maxY: CGFloat = -1
        var xPos = sectionInset.left
        for a in attributes {
            if a.frame.maxY > maxY {
                xPos = sectionInset.left
            }
            a.frame.origin.x = xPos
            xPos += a.frame.width + minimumInteritemSpacing
            maxY = max(a.frame.maxY, maxY)
        }
        return attributes
    }
}
