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
        case clear
        case ruby
        
        var color: NSColor {
            switch self {
            case .clear:
                return NSColor.clear
            case .ruby:
                return NSColor(calibratedRed: 0.878, green: 0.666, blue: 0.372, alpha: 1)
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
        viewModel = nil
        tagTitleLabel.stringValue = ""
    }
}

extension TagItemCell {
    private func bindTagItemCellViewModel() {
        viewModel.displayTagTitle
            .bind(to: tagTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.selected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { selected in
                self.backgroundBox.fillColor = selected ? Colors.ruby.color : Colors.clear.color
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
            .subscribe(onNext: {
                self.viewModel.deleteTagButtonTapped()
            }).disposed(by: disposeBag)
        
        viewModel.deletable
            .distinctUntilChanged()
            .map { !$0 }
            .bind(to: deleteTagButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.selectable
            .map { !$0 }
            .distinctUntilChanged()
            .bind(to: selectTagButton.rx.isHidden)
            .disposed(by: disposeBag)
    }
}

class TagItemCellViewModel {
    let tagItem: BehaviorRelay<TagItem>
    let numberOfUsed: BehaviorRelay<Int>
    let deleteRequested = PublishSubject<TagItemCellViewModel>()
    let selected: BehaviorRelay<Bool>
    
    let deletable: BehaviorRelay<Bool>
    let selectable: BehaviorRelay<Bool>
    let hideNumberOfUsed: BehaviorRelay<Bool>
    
    let displayTagTitle = BehaviorRelay<String>(value: "")
    let disposeBag = DisposeBag()
    
    init(tagItem: TagItem, selected: Bool = false, hideNumberOfUsed: Bool = true,
         deletable: Bool = false, selectable: Bool = false, numberOfUsed: Int = 0) {
        self.tagItem = BehaviorRelay<TagItem>(value: tagItem)
        self.selected = BehaviorRelay<Bool>(value: selected)
        self.deletable = BehaviorRelay<Bool>(value: deletable)
        self.selectable = BehaviorRelay<Bool>(value: selectable)
        self.numberOfUsed = BehaviorRelay<Int>(value: numberOfUsed)
        self.hideNumberOfUsed = BehaviorRelay<Bool>(value: hideNumberOfUsed)
        
        bindDisplayText()
    }
    
    private func toggleTag() {
        let flag = !selected.value
        selected.accept(flag)
    }
    
    func selectTagButtonTapped() {
        toggleTag()
    }
    
    func deleteTagButtonTapped() {
        deleteRequested.onNext(self)
    }
}

extension TagItemCellViewModel {
    private func bindDisplayText() {
        Observable
            .combineLatest(
                tagItem.asObservable(),
                numberOfUsed.asObservable(),
                hideNumberOfUsed.asObservable())
            .flatMapLatest { tagItem, numberOfUsed, hideNumberOfUsed -> Observable<String> in
                if hideNumberOfUsed {
                    return .just("#\(tagItem.title)")
                } else {
                    return .just("#\(tagItem.title)  \(numberOfUsed)")
                }
            }.bind(to: displayTagTitle)
            .disposed(by: disposeBag)
    }
}
