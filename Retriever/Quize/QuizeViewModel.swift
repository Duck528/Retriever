//
//  QuizeViewModel.swift
//  Retriever
//
//  Created by thekan on 13/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift
import RxCocoa

class QuizeViewModel {
    let words = BehaviorRelay<[WordItem]>(value: [])
    var totalWordsCountObs: Observable<Int> {
        return words
            .map { $0.count }
    }
    let easyLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let mediumLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let difficultyLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let undefinedLevelFilterOn = BehaviorRelay<Bool>(value: false)
    
    private let fetchLocalWordUsecase: FetchLocalWordUsecase
    private let disposeBag = DisposeBag()
    
    init() {
        self.fetchLocalWordUsecase = Assembler().resolve()
        fetchAllLocalWord()
    }
    
    func fetchAllLocalWord() {
        fetchLocalWordUsecase.execute()
            .bind(to: words)
            .disposed(by: disposeBag)
    }
}
