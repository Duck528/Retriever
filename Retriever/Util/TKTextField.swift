//
//  THTextField.swift
//  Retriever
//
//  Created by thekan on 29/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import AppKit

class TKBackspaceDetectingTextField: NSTextField {
    var onBackwardDetected: (() ->())?
    
    override func deleteBackward(_ sender: Any?) {
        super.deleteBackward(sender)
        onBackwardDetected?()
    }
    
    
}
