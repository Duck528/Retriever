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
    
    enum Colors {
        case lightBlue
        case lightGray
        
        var color: NSColor {
            switch self {
            case .lightBlue:
                return NSColor(red: 68, green: 144, blue: 255)
            case .lightGray:
                return NSColor.lightGray
            }
        }
    }
    
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!
    @IBOutlet weak var selectTagButton: NSButton!
    
    var viewModel: TagItemCellViewModel!
    var disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindTagItemCellViewModel()
        bindSelectButton()
    }
    
    override func prepareForReuse() {
        clearCell()
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundBox.cornerRadius = 60
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
                self.titleTextField.stringValue = tagItem.title
            }).disposed(by: disposeBag)
        
        viewModel.selected
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { selected in
//                self.backgroundBox.fillColor = selected ? NSColor.red : Colors.lightGray.color
            }).disposed(by: disposeBag)
    }
    
    private func bindSelectButton() {
        selectTagButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.toggleTag()
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
    
    func toggleTag() {
        let flag = !selected.value
        selected.accept(flag)
    }
}
