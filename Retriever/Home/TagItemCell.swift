//
//  TagItemCell.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class TagItemCell: NSCollectionViewItem, BindableType {
    typealias ViewModelType = TagItemCellViewModel
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var backgroundView: NSView!
    
    var viewModel: TagItemCellViewModel!
    var disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindTagItemCellViewwModel()
    }
    
    override func prepareForReuse() {
        clearCell()
        super.prepareForReuse()
    }
}

extension TagItemCell {
    private func clearCell() {
        disposeBag = DisposeBag()
        titleTextField.stringValue = ""
    }
}

extension TagItemCell {
    private func bindTagItemCellViewModel() {
        viewModel.tagItem
            .subscribe(onNext: { tagItem in
                print("title: \(tagItem.title)")
                self.titleTextField.stringValue = tagItem.title
            }).disposed(by: disposeBag)
        
        viewModel.selected
            .subscribe(onNext: { selected in
                print("selected: \(selected)")
            }).disposed(by: disposeBag)
    }
}

class TagItemCellViewModel {
    let tagItem: BehaviorRelay<TagItem>
    var selected: BehaviorRelay<Bool>
    
    init(tagItem: TagItem, selected: Bool = false) {
        self.tagItem = BehaviorRelay<TagItem>(value: tagItem)
        self.selected = BehaviorRelay<Bool>(value: selected)
    }
}
