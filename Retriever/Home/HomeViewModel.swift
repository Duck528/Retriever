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
        case updateWordEditMode
        case updateWordAppendMode
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
    var editWordIndex: IndexPath? {
        didSet {
            if editWordIndex == nil {
                clearWordItemComponents()
                viewAction.onNext(.updateWordAppendMode)
            } else {
                updateWordItemComponents()
                viewAction.onNext(.updateWordEditMode)
            }
        }
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
    
    func selectWordToEdit(at indexPath: IndexPath) {
        editWordIndex = indexPath
        viewAction.onNext(.updateWordEditMode)
        viewAction.onNext(.showAppendWordSection)
    }
    
    func deselectWordToEdit() {
        editWordIndex = nil
        viewAction.onNext(.updateWordAppendMode)
    }
    
    func cancelAppendWordButtonTapped() {
        viewAction.onNext(.hideAppendWordSection)
    }
    
    func cancelEditWordButtonTapped() {
        editWordIndex = nil
        viewAction.onNext(.hideAppendWordSection)
    }
    
    func deleteSelectedWordButtonTapped() {
        
    }
    
    func updateSelectedWordButtonTapped() {
        
    }
    
    func presentAppendWordButtonTapped() {
        viewAction.onNext(.showAppendWordSection)
    }
    
    func saveWordButtonTapped() {
        let wordItem = configureWordItem()
        saveWordUsecase.execute(with: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .subscribe(onNext: { savedWordItem in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
            }).disposed(by: disposeBag)
    }
    
    func saveWordContinouslyButtonTapped() {
        let wordItem = configureWordItem()
        saveWordUsecase.execute(with: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .subscribe(onNext: { savedWordItem in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
            }).disposed(by: disposeBag)
    }
    
    private func fetchWordItems() {
        fetchWordUsecase.execute()
            .do(onNext: { wordItems in
                let allTags = wordItems
                    .flatMap { $0.tags }
                    .map { TagItemCellViewModel(tagItem: $0) }
                self.allTags.accept(allTags)
            })
            .map { $0.map { WordItemCellViewModel(wordItem: $0) } }
            .bind(to: wordItems)
            .disposed(by: disposeBag)
    }
    
    private func updateWordItemComponents() {
        guard let editWordIndex = editWordIndex else {
            return
        }
        let editWordItem = wordItems.value[editWordIndex.item].wordItem.value
        wordText.accept(editWordItem.word)
        meanText.accept(editWordItem.mean)
        additionalInfoText.accept(editWordItem.additionalInfo)
    }
    
    private func clearWordItemComponents() {
        wordText.accept("")
        meanText.accept("")
        additionalInfoText.accept("")
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
}
