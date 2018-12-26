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
    
    var viewModel: WordItemCellViewModel!
    
    func bindViewModel() {
        
    }
}


class WordItemCellViewModel {
    let wordItem: BehaviorRelay<WordItem>
    
    init(wordItem: WordItem) {
        self.wordItem = BehaviorRelay<WordItem>(value: wordItem)
    }
}
