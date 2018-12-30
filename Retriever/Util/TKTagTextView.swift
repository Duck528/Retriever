//
//  TKTagTextView.swift
//  Retriever
//
//  Created by thekan on 29/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import AppKit

protocol TKTagTextViewDelegate {
    func numberOfItems(in tagTextView: TKTagTextView) -> Int
    func tagTextView(_ tagTextView: TKTagTextView, item at: IndexPath) -> TKTagView
    func tagTextView(_ tagTextView: TKTagTextView, sizeOfItem at: IndexPath) -> CGSize
}

class TKTagTextView: NSScrollView {
    let textField = TKBackspaceDetectingTextField(string: "")
    var tagViews: [TKTagView] = []
    var delegate: TKTagTextViewDelegate?
    
    @IBInspectable var verticalScrollable: Bool = false
    @IBInspectable var horizontalScrollable: Bool = false
    @IBInspectable var insets = NSEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    @IBInspectable var interItemSpacing: CGFloat = 5
    @IBInspectable var interRowSpacing: CGFloat = 5
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    func reloadData() {
        
    }
}

extension TKTagTextView {
    private func commonInit() {
        
    }
    
    private func positioningViews() {
        guard let delegate = delegate else {
            return
        }
        let numberOfTags = delegate.numberOfItems(in: self)
        for index in 0 ..< numberOfTags {
            let indexPath = IndexPath(item: index, section: 0)
            let tagView = delegate.tagTextView(self, item: indexPath)
            tagView.bounds.size = delegate.tagTextView(self, sizeOfItem: indexPath)
            tagViews.append(tagView)
        }
        
        let contentWidth = bounds.size.width - (insets.left + insets.right)
        var leftSpacing = insets.left
        var topSpacing = insets.top
        
        for tagView in tagViews {
            leftSpacing + tagView.bounds.width
        }
    }
}
