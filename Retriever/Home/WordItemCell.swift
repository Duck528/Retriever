//
//  WordItemCell.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

class WordItemCell: NSCollectionViewItem, BindableType {
    typealias ViewModelType = WordItemCellViewModel
    
    @IBOutlet weak var wordTextField: NSTextField!
    @IBOutlet weak var meanTextField: NSTextField!
    @IBOutlet weak var syncStatusView: NSView!
    @IBOutlet weak var syncWordButton: NSButton!
    
    var viewModel: WordItemCellViewModel!
    var disposeBag = DisposeBag()
    
    func bindViewModel() {
        viewModel.wordItem
            .subscribe(onNext: { wordItem in
                self.wordTextField.stringValue = wordItem.word
                self.meanTextField.stringValue = wordItem.mean
                self.syncStatusView.isHidden = wordItem.status == .stable
            }).disposed(by: disposeBag)
    }
    
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}

class WordItemCellViewModel {
    let wordItem: BehaviorRelay<WordItem>
    
    init(wordItem: WordItem) {
        self.wordItem = BehaviorRelay<WordItem>(value: wordItem)
    }
}
