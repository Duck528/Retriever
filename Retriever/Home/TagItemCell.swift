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
    
    @IBOutlet weak var tagTitleLabel: NSTextField!
    @IBOutlet weak var backgroundBox: NSBox!
    @IBOutlet weak var selectTagButton: NSButton!
    @IBOutlet weak var deleteTagButton: NSButton!
    
    var viewModel: TagItemCellViewModel!
    var disposeBag = DisposeBag()
    
    func bindViewModel() {
        bindTagItemCellViewModel()
        bindSelectButton()
        bindDeleteButton()
    }
    
    override func prepareForReuse() {
        clearCell()
        super.prepareForReuse()
    }
}

extension TagItemCell {
    private func clearCell() {
        disposeBag = DisposeBag()
        tagTitleLabel.stringValue = ""
    }
}

extension TagItemCell {
    private func bindTagItemCellViewModel() {
        viewModel.tagItem
            .subscribe(onNext: { tagItem in
                self.tagTitleLabel.stringValue = tagItem.title
            }).disposed(by: disposeBag)
        
        viewModel.selected
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { selected in
                self.backgroundBox.fillColor = selected ? NSColor.red : NSColor.clear
            }).disposed(by: disposeBag)
    }
    
    private func bindSelectButton() {
        selectTagButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: {
                self.viewModel.selectTagButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    private func bindDeleteButton() {
        deleteTagButton.rx.tap
            .throttle(0.5, latest: true, scheduler: MainScheduler.instance)
            .filter { !self.viewModel.deletable.value }
            .subscribe(onNext: {
                self.viewModel.deleteTagButtonTapped()
            }).disposed(by: disposeBag)
        
        viewModel.deletable
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: deleteTagButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

class TagItemCellViewModel {
    let tagItem: BehaviorRelay<TagItem>
    let selected: BehaviorRelay<Bool>
    let deletable: BehaviorRelay<Bool>
    
    init(tagItem: TagItem, selected: Bool = false, deletable: Bool = false) {
        self.tagItem = BehaviorRelay<TagItem>(value: tagItem)
        self.selected = BehaviorRelay<Bool>(value: selected)
        self.deletable = BehaviorRelay<Bool>(value: deletable)
    }
    
    func toggleTag() {
        let flag = !selected.value
        selected.accept(flag)
    }
    
    func selectTagButtonTapped() {
        toggleTag()
    }
    
    func deleteTagButtonTapped() {
        
    }
}
