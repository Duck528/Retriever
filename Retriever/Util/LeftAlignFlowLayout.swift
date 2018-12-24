//
//  LeftAlignFlowLayout.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit

class LeftAlignFlowLayout: NSCollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        let attributesList = super.layoutAttributesForElements(in: rect)
        return attributesList
    }
}
