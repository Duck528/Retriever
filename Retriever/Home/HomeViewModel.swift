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
    
    let internetConnected = BehaviorRelay<Bool>(value: false)
    
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
    
    let syncDatabaseUsecase: SyncDatabaseUsecase
    let fetchLocalWordUsecase: FetchLocalWordUsecase
    let saveRemoteWordUsecase: SaveRemoteWordUsecase
    let saveLocalWordUsecase: SaveLocalWordUsecase
    
    let wordItems = BehaviorRelay<[WordItemCellViewModel]>(value: [])
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        syncDatabaseUsecase = Assembler().resolve()
        fetchLocalWordUsecase = Assembler().resolve()
        saveRemoteWordUsecase = Assembler().resolve()
        saveLocalWordUsecase = Assembler().resolve()
        bindReachability()
        fetchWordItemsAfterSync()
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
        saveWordToLocal(wordItem)
    }
    
    private func saveWordToLocal(_ wordItem: WordItem) {
        saveLocalWordUsecase.execute(wordItem: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .subscribe(onNext: { savedWordItem in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
            }).disposed(by: disposeBag)
    }
    
    func saveWordContinouslyButtonTapped() {
        let wordItem = configureWordItem()
        saveRemoteWordUsecase.execute(with: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .subscribe(onNext: { savedWordItem in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
            }).disposed(by: disposeBag)
    }
    
    private func fetchWordItemsWithoutSync() {
        fetchLocalWordUsecase.execute()
            .do(onNext: { wordItems in
                print(wordItems)
                let allTags = wordItems
                    .flatMap { $0.tags }
                    .map { TagItemCellViewModel(tagItem: $0) }
                self.allTags.accept(allTags)
            }, onError: { error in
                print(error.localizedDescription)
            })
            .map { $0.map { WordItemCellViewModel(wordItem: $0) } }
            .bind(to: wordItems)
            .disposed(by: disposeBag)
    }
    
    private func fetchWordItemsAfterSync() {
        let fetchWordItemsObs = fetchLocalWordUsecase.execute()
            .map { $0.map { WordItemCellViewModel(wordItem: $0) } }
        
        syncDatabaseUsecase.execute()
            .andThen(fetchWordItemsObs)
            .do(onNext: { wordItems in
                print(wordItems)
                let allTags = wordItems
                    .flatMap { $0.wordItem.value.tags }
                    .map { TagItemCellViewModel(tagItem: $0) }
                self.allTags.accept(allTags)
            }, onError: { error in
                print(error.localizedDescription)
            })
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
    
    private func bindReachability() {
        Reachability.reachable
            .bind(to: internetConnected)
            .disposed(by: disposeBag)
        
        internetConnected
            .skip(1)
            .subscribe(onNext: { connected in
                if connected {
                    self.fetchWordItemsAfterSync()
                } else {
                    self.fetchWordItemsWithoutSync()
                }
            }).disposed(by: disposeBag)
    }
}

extension HomeViewModel {
    private func configureWordItem() -> WordItem {
        let wordItem = WordItem(
            word: wordText.value,
            mean: meanText.value,
            lastModified: Date(),
            additionalInfo: additionalInfoText.value,
            difficulty: difficulty.value)
        return wordItem
    }
}
