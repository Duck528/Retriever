//
//  HomeViewModel.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    
    enum ViewAction {
        case hideAppendWordSection
        case showAppendWordSection
    }
    
    let wordToSearch = BehaviorRelay<String>(value: "")
    let viewAction = PublishSubject<ViewAction>()
    
    let wordText = BehaviorRelay<String>(value: "")
    let meanText = BehaviorRelay<String>(value: "")
    let additionalInfoText = BehaviorRelay<String>(value: "")
    let difficulty = BehaviorRelay<Int>(value: WordItem.WordDifficulty.easy.rawValue)
    
    var wordAppendable: Observable<Bool> {
        let hasWordObs = wordText.asObservable()
            .map { !$0.isEmpty }
        let hasMeanObs = meanText.asObservable()
            .map { !$0.isEmpty }
        
        return Observable.combineLatest(hasWordObs, hasMeanObs)
            .map { $0 && $1 }
    }
    
    let fetchWordUsecase: FetchWordUsecase
    let saveWordUsecase: SaveWordUsecase
    
    let wordItems = BehaviorRelay<[WordItemCellViewModel]>(value: [])
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        fetchWordUsecase = Assembler().resolve()
        saveWordUsecase = Assembler().resolve()
        fetchWordItems()
    }
    
    private func fetchWordItems() {
        fetchWordUsecase.execute()
            .do(onNext: { print($0.count) })
            .map { $0.map { WordItemCellViewModel(wordItem: $0) } }
            .bind(to: wordItems)
            .disposed(by: disposeBag)
    }
    
    func cancelAppendWordButtonTapped() {
        viewAction.onNext(.hideAppendWordSection)
    }
    
    func presentAppendWordButtonTapped() {
        viewAction.onNext(.showAppendWordSection)
    }
    
    func saveWordButtonTapped() {
            let wordItem = configureWordItem()
        saveWordUsecase.execute(with: wordItem)
            .subscribe(onNext: { savedWordItem in
                self.printWordItem(savedWordItem)
            }).disposed(by: disposeBag)
    }
    
    func saveWordContinouslyButtonTapped() {
        let wordItem = configureWordItem()
        saveWordUsecase.execute(with: wordItem)
            .subscribe(onNext: { savedWordItem in
                self.printWordItem(savedWordItem)
            }).disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    private func configureWordItem() -> WordItem {
        let wordItem = WordItem(
            word: wordText.value,
            mean: meanText.value,
            additionalInfo: additionalInfoText.value,
            difficulty: difficulty.value)
        return wordItem
    }
    
    private func printWordItem(_ wordItem: WordItem) {
        print("word: \(wordItem.word)")
        print("mean: \(wordItem.mean)")
        print("difficulty: \(wordItem.difficulty)")
    }
}
