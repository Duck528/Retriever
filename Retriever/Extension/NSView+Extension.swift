//
//  NSView+Extension.swift
//  Retriever
//
//  Created by thekan on 25/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit

extension NSView {
    func findConstraint(for attribute: NSLayoutConstraint.Attribute) -> NSLayoutConstraint? {
        let view = (attribute == .width || attribute == .height) ? self : superview
        return view?.constraints.first { $0.hasItem(self) && $0.hasAttribute(attribute) }
    }
}

extension NSLayoutConstraint {
    func hasItem(_ item: NSView) -> Bool {
        let items = [firstItem, secondItem].compactMap { $0 as? NSView }
        return items.contains(item)
    }
    
    func hasAttribute(_ attribute: NSLayoutConstraint.Attribute) -> Bool {
        return [firstAttribute, secondAttribute].contains(attribute)
    }
}
