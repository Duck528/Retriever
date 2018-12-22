//
//  NSColor+Extension.swift
//  Retriever
//
//  Created by thekan on 23/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit

extension NSColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        let redRatio = red / 255.0
        let greenRatio = green / 255.0
        let blueRatio = blue / 255.0
        self.init(calibratedRed: redRatio, green: greenRatio, blue: blueRatio, alpha: 1)
    }
}
