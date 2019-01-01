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
        case reloadWordAtIndex(IndexPath)
    }
    
    enum SyncStatus {
        case unSynced
        case progress
        case stable
    }
    
    let wordToSearch = BehaviorRelay<String>(value: "")
    let viewAction = PublishSubject<ViewAction>()
    
    let wordText = BehaviorRelay<String>(value: "")
    let meanText = BehaviorRelay<String>(value: "")
    let additionalInfoText = BehaviorRelay<String>(value: "")
    let difficulty = BehaviorRelay<Int>(value: WordItem.WordDifficulty.easy.rawValue)
    
    let syncStatus = BehaviorRelay<SyncStatus>(value: .stable)
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
    let updateLocalWordUsecase: UpdateLocalWordUsecase
    
    let wordItems = BehaviorRelay<[WordItemCellViewModel]>(value: [])
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        syncDatabaseUsecase = Assembler().resolve()
        fetchLocalWordUsecase = Assembler().resolve()
        saveRemoteWordUsecase = Assembler().resolve()
        saveLocalWordUsecase = Assembler().resolve()
        updateLocalWordUsecase = Assembler().resolve()
        bindReachability()
        bindSyncStatus()
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
    
    // 삭제 버튼이 눌린 경우
    func deleteSelectedWordButtonTapped() {
        
    }
    
    // 업데이트 버튼이 눌린 경우
    func updateSelectedWordButtonTapped() {
        guard let editWordIndex = editWordIndex else {
            return
        }
        let wordItem = wordItems.value[editWordIndex.item].wordItem.value
        wordItem.word = wordText.value
        wordItem.mean = meanText.value
        wordItem.tags = []
        wordItem.additionalInfo = additionalInfoText.value
        wordItem.difficulty = WordItem.WordDifficulty.parse(int: difficulty.value)
        
        updateLocalWordUsecase.execute(wordItem: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { updatedWordItem in
                var updatedWordItems = self.wordItems.value
                updatedWordItems[editWordIndex.item] = updatedWordItem
                self.wordItems.accept(updatedWordItems)
                self.clearWordItemComponents()
                self.viewAction.onNext(.hideAppendWordSection)
            }).disposed(by: disposeBag)
    }
    
    func presentAppendWordButtonTapped() {
        viewAction.onNext(.showAppendWordSection)
    }
    
    // 추가하기 버튼이 눌린 경우
    func saveWordButtonTapped() {
        let wordItem = configureWordItem()
        saveWordToLocal(wordItem)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .completed:
                    self.clearWordItemComponents()
                    self.viewAction.onNext(.hideAppendWordSection)
                case .error(let error):
                    print(error.localizedDescription)
                }
            }.disposed(by: disposeBag)
    }
    
    // 계속해서 더하기 버튼이 눌린 경우
    func saveWordContinouslyButtonTapped() {
        let wordItem = configureWordItem()
        saveWordToLocal(wordItem)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .completed:
                    self.clearWordItemComponents()
                case .error(let error):
                    print(error.localizedDescription)
                }
            }.disposed(by: disposeBag)
    }
    
    private func saveWordToLocal(_ wordItem: WordItem) -> Completable {
        return saveLocalWordUsecase.execute(wordItem: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .flatMapLatest { savedWordItem -> Observable<WordItemCellViewModel> in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
                return .just(savedWordItem)
            }.ignoreElements()
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
    
    private func bindSyncStatus() {
        wordItems
            .skip(1)
            .map { $0.map { $0.wordItem.value.status } }
            .map { $0.filter { $0 != .stable } }
            .map { $0.count > 0 ? SyncStatus.unSynced : SyncStatus.stable }
            .bind(to: syncStatus)
            .disposed(by: disposeBag)
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
