//
//  NSFont+Extension.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import AppKit

extension NSFont {
    func size(text: String, constrainedToWidth width: CGFloat) -> CGSize {
        let attributes = [NSAttributedString.Key.font: self]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let frameSetter = CTFramesetterCreateWithAttributedString(attributedText)
        
        return CTFramesetterSuggestFrameSizeWithConstraints(
            frameSetter,
            CFRange(location: 0, length: 0),
            nil,
            CGSize(width: width, height: .greatestFiniteMagnitude),
            nil)
    }
    
    class func helveticaNeueBold(size: CGFloat) -> NSFont {
        return NSFont(name: "Helvetica-Neue-Bold", size: size) ?? NSFont.systemFont(ofSize: size)
    }
}
