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
        case updateDiffculty(WordItem.WordDifficulty)
        case reloadWordItems
        case reloadWordAtIndex(IndexPath)
        case scrollToWord(IndexPath)
        case clearInputTagText
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
    let tagText = BehaviorRelay<String>(value: "")
    let wordTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let additionalInfoText = BehaviorRelay<String>(value: "")
    let difficulty = BehaviorRelay<Int>(value: WordItem.WordDifficulty.easy.rawValue)
    
    let syncStatus = BehaviorRelay<SyncStatus>(value: .stable)
    let internetConnected = BehaviorRelay<Bool>(value: false)
    
    let numberOfUpdatedWords = BehaviorRelay<Int>(value: 0)
    let numberOfDeletedWords = BehaviorRelay<Int>(value: 0)
    
    let latestSyncTime = BehaviorRelay<Date?>(value: nil)
    
    let easyDifficultyChecked = BehaviorRelay<Bool>(value: false)
    let mediumDifficultyChecked = BehaviorRelay<Bool>(value: false)
    let hardDifficultyChecked = BehaviorRelay<Bool>(value: false)
    let undefinedDifficultyChecked = BehaviorRelay<Bool>(value: false)
    let filterWordsMap = BehaviorRelay<[WordItem.WordDifficulty: Bool]>(value: [:])
    
    let intervalMinTimer = Observable<Int>.interval(60, scheduler: ConcurrentDispatchQueueScheduler(qos: .default))
    
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
            if let indexPath = editWordIndex {
                updateWordItemComponents()
                updateSelectedStatusInWordItems(true)
                viewAction.onNext(.updateWordEditMode)
                viewAction.onNext(.updateWordEditMode)
                viewAction.onNext(.showAppendWordSection)
                viewAction.onNext(.scrollToWord(indexPath))
            } else {
                clearWordItemComponents()
                viewAction.onNext(.updateWordAppendMode)
                viewAction.onNext(.hideAppendWordSection)
                viewAction.onNext(.updateDiffculty(WordItem.WordDifficulty.easy))
            }
        }
        willSet {
            updateSelectedStatusInWordItems(false)
        }
    }
    
    let syncDatabaseUsecase: SyncDatabaseUsecase
    let fetchLocalWordUsecase: FetchLocalWordUsecase
    let saveRemoteWordUsecase: SaveRemoteWordUsecase
    let saveLocalWordUsecase: SaveLocalWordUsecase
    let updateLocalWordUsecase: UpdateLocalWordUsecase
    let deleteLocalWordUsecase: DeleteLocalWordUsecase
    let fetchNumberOfUpdatedWordUsecase: FetchNumberOfUpdatedWordUsecase
    let fetchNumberOfDeletedWordUsecase: FetchNumberOfDeletedWordUsecase
    let fetchAllLocalTagsUsecase: FetchAllLocalTagsUsecase
    
    let fetchLatestSyncTimeUsecase: FetchLatestSyncTimeUsecase
    let updateLatestSyncTimeUsecase: UpdateLatestSyncTimeUsecase
    
    let wordItems = BehaviorRelay<[WordItemCellViewModel]>(value: [])
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let disposeBag = DisposeBag()
    
    init() {
        syncDatabaseUsecase = Assembler().resolve()
        fetchLocalWordUsecase = Assembler().resolve()
        saveRemoteWordUsecase = Assembler().resolve()
        saveLocalWordUsecase = Assembler().resolve()
        updateLocalWordUsecase = Assembler().resolve()
        deleteLocalWordUsecase = Assembler().resolve()
        fetchNumberOfUpdatedWordUsecase = Assembler().resolve()
        fetchNumberOfDeletedWordUsecase = Assembler().resolve()
        fetchLatestSyncTimeUsecase = Assembler().resolve()
        updateLatestSyncTimeUsecase = Assembler().resolve()
        fetchAllLocalTagsUsecase = Assembler().resolve()
        
        bindReachability()
        bindSyncStatus()
        bindNumberOfWords()
        bindFilterWordsByDifficultyOptions()
        bindFilterWordsBySearchedText()
        bindMinIntervalTimer()
        bindWordItemsCountChanged()
        
        fetchWordItemsWithoutSync()
        fetchLatestSyncTime()
        fetchAllLocalTags()
    }
    
    func selectWordToEdit(at indexPath: IndexPath) {
        guard indexPath.item >= 0, indexPath.item < wordItems.value.count else {
            return
        }
        
        // 같은 index가 중복으로 선택된 경우 nil 삽입
        if indexPath.item == editWordIndex?.item {
            viewAction.onNext(.updateDiffculty(WordItem.WordDifficulty.easy))
            viewAction.onNext(.hideAppendWordSection)
            editWordIndex = nil
            return
        }
        
        editWordIndex = indexPath
        let wordItem = wordItems.value[indexPath.item].wordItem.value
        viewAction.onNext(.updateDiffculty(wordItem.difficulty))
    }
    
    func deselectWordToEdit() {
        editWordIndex = nil
        viewAction.onNext(.updateWordAppendMode)
        viewAction.onNext(.updateDiffculty(WordItem.WordDifficulty.easy))
    }
    
    func cancelAppendWordButtonTapped() {
        viewAction.onNext(.hideAppendWordSection)
        viewAction.onNext(.updateDiffculty(WordItem.WordDifficulty.easy))
    }
    
    func cancelEditWordButtonTapped() {
        editWordIndex = nil
    }
    
    // 동기화 버튼이 눌린 경우
    func syncButtonTapped() {
        guard internetConnected.value else {
            return
        }
        syncStatus.accept(.progress)
        fetchWordItemsAfterSync()
    }
    
    // 삭제 버튼이 눌린 경우
    func deleteSelectedWordButtonTapped() {
        guard let indexPath = editWordIndex else {
            return
        }
        guard indexPath.item >= 0, indexPath.item < wordItems.value.count else {
            return
        }
        
        let wordItem = wordItems.value[indexPath.item].wordItem.value
        
        deleteLocalWordUsecase.execute(wordItem: wordItem)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .completed:
                    var deletedWordItems = self.wordItems.value
                    deletedWordItems.remove(at: indexPath.item)
                    self.wordItems.accept(deletedWordItems)
                    self.viewAction.onNext(.hideAppendWordSection)
                    self.viewAction.onNext(ViewAction.reloadWordAtIndex(indexPath))
                    self.clearWordItemComponents()
                case .error(let error):
                    print(error.localizedDescription)
                }
            }.disposed(by: disposeBag)
    }
    
    // 업데이트 버튼이 눌린 경우
    func updateSelectedWordButtonTapped() {
        guard let indexPath = editWordIndex else {
            return
        }
        
        let wordItem = wordItems.value[indexPath.item].wordItem.value
        wordItem.word = wordText.value
        wordItem.mean = meanText.value
        wordItem.tags = wordTags.value
            .map { $0.tagItem.value }
        wordItem.additionalInfo = additionalInfoText.value
        wordItem.difficulty = WordItem.WordDifficulty.parse(int: difficulty.value)
        
        updateLocalWordUsecase.execute(wordItem: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .flatMapLatest { wordItem -> Observable<WordItemCellViewModel> in
                self.fetchAllLocalTags()
                return .just(wordItem)
            }.observeOn(MainScheduler.instance)
            .subscribe(onNext: { updatedWordItem in
                var updatedWordItems = self.wordItems.value
                guard indexPath.item >= 0, indexPath.item < updatedWordItems.count else {
                    return
                }
                updatedWordItems[indexPath.item] = updatedWordItem
                self.wordItems.accept(updatedWordItems)
                self.editWordIndex = nil
                self.viewAction.onNext(.reloadWordAtIndex(indexPath))
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
    
    func inputTagReturnKeyEntered() {
        let enteredTag = TagItem(title: tagText.value)
        let tagVM = TagItemCellViewModel(tagItem: enteredTag, deletable: true, selectable: false)
        tagVM.deleteRequested
            .subscribe(onNext: { cellViewModel in
                self.removeTag(to: cellViewModel)
            }).disposed(by: disposeBag)
        clearInputTagText()
        wordTags.accept(wordTags.value + [tagVM])
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

extension HomeViewModel {
    private func fetchWordItemsWithoutSync() {
        fetchLocalWordUsecase.execute()
            .do(onNext: { print("LocalFetchCount Without Sync: \($0.count)") })
            .map { $0.filter { self.filterWordsMap.value[$0.difficulty] ?? false } }
            .map { $0.filter {
                let filterWord = self.wordToSearch.value.lowercased()
                if filterWord.isEmpty {
                    return true
                } else {
                    return $0.word.lowercased().starts(with: filterWord)
                }
                }
            }.map { $0.map { WordItemCellViewModel(wordItem: $0) } }
            .map { self.filterWordItemsByTags(wordItems: $0, tags: self.getSelectedFilterTags()) }
            .subscribe(onNext: { wordItems in
                self.wordItems.accept(wordItems)
                self.viewAction.onNext(.reloadWordItems)
            }).disposed(by: disposeBag)
    }
    
    private func fetchWordItemsAfterSync() {
        let fetchWordItemsObs = fetchLocalWordUsecase.execute()
            .do(onNext: { print("LocalFetchCount With Sync: \($0.count)") })
            .map { $0.filter { self.filterWordsMap.value[$0.difficulty] ?? false } }
            .map { $0.filter {
                let filterWord = self.wordToSearch.value.lowercased()
                if filterWord.isEmpty {
                    return true
                } else {
                    return $0.word.lowercased().starts(with: filterWord)
                }
            }}
            .map { $0.map { WordItemCellViewModel(wordItem: $0) } }
            .map { self.filterWordItemsByTags(wordItems: $0, tags: self.getSelectedFilterTags()) }
        
        syncDatabaseUsecase.execute()
            .andThen(fetchWordItemsObs)
            .flatMapLatest { wordItems -> Observable<[WordItemCellViewModel]> in
                return self.updateLatestSyncTimeUsecase
                    .execute()
                    .map { _ in wordItems }
            }.flatMapLatest { wordItems -> Observable<[WordItemCellViewModel]> in
                return self.fetchLatestSyncTimeUsecase
                    .execute()
                    .do(onNext: { latestSyncTime in
                        self.latestSyncTime.accept(latestSyncTime)
                    }).map { _ in wordItems }
            }.subscribe(onNext: { wordItems in
                self.wordItems.accept(wordItems)
                self.viewAction.onNext(.reloadWordItems)
            }).disposed(by: disposeBag)
    }
    
    private func fetchLatestSyncTime() {
        fetchLatestSyncTimeUsecase.execute()
            .bind(to: latestSyncTime)
            .disposed(by: disposeBag)
    }
    
    private func fetchAllLocalTags() {
        fetchAllLocalTagsUsecase.execute()
            .map { tagItems in
                tagItems.map { TagItemCellViewModel(tagItem: $0, hideNumberOfUsed: false, selectable: true) }
            }.flatMapLatest { tags -> Observable<[TagItemCellViewModel]> in
                let tagCountDict = tags
                    .map { $0.tagItem.value.title }
                    .reduce([String: Int]()) { result, tagTitle in
                        var result = result
                        if let value = result[tagTitle] {
                            result[tagTitle] = value + 1
                        } else {
                            result[tagTitle] = 1
                        }
                        return result
                    }
                
                let prevAllTags = self.allTags.value
                var filteredTags: [TagItemCellViewModel] = []
                for tag in tags {
                    if filteredTags.contains(where: { $0.tagItem.value.title == tag.tagItem.value.title }) {
                        continue
                    }

                    tag.selected
                        .subscribe(onNext: { isSelected in
                            self.fetchWordItemsWithoutSync()
                        }).disposed(by: self.disposeBag)
                    let tagCount = tagCountDict[tag.tagItem.value.title] ?? 0
                    tag.numberOfUsed.accept(tagCount)
                    
                    if let prevTag = prevAllTags.first(where: { $0.tagItem.value.title == tag.tagItem.value.title }) {
                        tag.selected.accept(prevTag.selected.value)
                    }
                    
                    filteredTags.append(tag)
                }
                return .just(filteredTags)
            }.bind(to: allTags)
            .disposed(by: disposeBag)
    }
    
    private func getSelectedFilterTags() -> [TagItem] {
        return allTags.value
            .filter { $0.selected.value }
            .map { $0.tagItem.value }
    }
    
    private func filterWordItemsByTags(wordItems: [WordItemCellViewModel], tags: [TagItem]) -> [WordItemCellViewModel] {
        guard tags.count > 0 else {
            return wordItems
        }
        
        var mutableWordItems: [WordItemCellViewModel] = []
        for wordItem in wordItems {
            let wordTags = wordItem.wordItem.value.tags
            for wordTag in wordTags {
                if tags.contains(where: { wordTag.title == $0.title }) {
                    mutableWordItems.append(wordItem)
                    break
                }
            }
        }
        return mutableWordItems
    }
}

extension HomeViewModel {
    private func saveWordToLocal(_ wordItem: WordItem) -> Completable {
        return saveLocalWordUsecase.execute(wordItem: wordItem)
            .map { WordItemCellViewModel(wordItem: $0) }
            .flatMapLatest { savedWordItem -> Observable<WordItemCellViewModel> in
                let appendedWordItems = self.wordItems.value + [savedWordItem]
                self.wordItems.accept(appendedWordItems)
                let index = self.wordItems.value.count - 1
                self.viewAction.onNext(ViewAction.reloadWordAtIndex(IndexPath(item: index, section: 0)))
                return .just(savedWordItem)
            }.ignoreElements()
    }
    
    private func updateWordItemComponents() {
        guard
            let editWordIndex = editWordIndex,
            editWordIndex.item >= 0, editWordIndex.item < wordItems.value.count else {
                return
        }
        
        let editWordItem = wordItems.value[editWordIndex.item].wordItem.value
        wordText.accept(editWordItem.word)
        meanText.accept(editWordItem.mean)
        let tagCellViewModels = editWordItem.tags
            .map { TagItemCellViewModel(tagItem: $0, deletable: true) }
        tagCellViewModels.forEach { cellViewModel in
            cellViewModel.deleteRequested
                .subscribe(onNext: { cellViewModel in
                    self.removeTag(to: cellViewModel)
                }).disposed(by: self.disposeBag)
        }
        wordTags.accept(tagCellViewModels)
        additionalInfoText.accept(editWordItem.additionalInfo)
    }
    
    private func updateSelectedStatusInWordItems(_ selected: Bool) {
        guard
            let indexPath = editWordIndex,
            indexPath.item >= 0, indexPath.item < wordItems.value.count else {
                return
        }
        wordItems.value[indexPath.item].selected.accept(selected)
    }
    
    private func clearWordItemComponents() {
        wordText.accept("")
        meanText.accept("")
        tagText.accept("")
        viewAction.onNext(.clearInputTagText)
        wordTags.accept([])
        additionalInfoText.accept("")
    }
    
    private func removeTag(to cellViewModel: TagItemCellViewModel) {
        if let index = wordTags.value.firstIndex(where: { $0 === cellViewModel }) {
            var removedWordTags = wordTags.value
            removedWordTags.remove(at: index)
            self.wordTags.accept(removedWordTags)
        }
    }
    
    private func clearInputTagText() {
        viewAction.onNext(.clearInputTagText)
    }
}

extension HomeViewModel {
    private func bindReachability() {
        Reachability.reachable
            .bind(to: internetConnected)
            .disposed(by: disposeBag)
        
        internetConnected
            .skip(1)
            .subscribe(onNext: { connected in
                print("internet connected: \(connected)")
            }).disposed(by: disposeBag)
    }
    
    private func bindSyncStatus() {
        Observable
            .combineLatest(numberOfUpdatedWords.skip(1), numberOfDeletedWords.skip(1))
            .skip(1)
            .map { $0 == 0 && $1 == 0 ? SyncStatus.stable : SyncStatus.unSynced }
            .bind(to: syncStatus)
            .disposed(by: disposeBag)
    }
    
    private func bindNumberOfWords() {
        wordItems
            .flatMapLatest { _ -> Observable<Int> in
                return self.fetchNumberOfUpdatedWordUsecase.execute()
            }.bind(to: numberOfUpdatedWords)
            .disposed(by: disposeBag)
        
        wordItems
            .flatMapLatest { _ -> Observable<Int> in
                return self.fetchNumberOfDeletedWordUsecase.execute()
            }.bind(to: numberOfDeletedWords)
            .disposed(by: disposeBag)
    }
    
    private func bindFilterWordsByDifficultyOptions() {
        Observable
            .combineLatest(easyDifficultyChecked, mediumDifficultyChecked,
                           hardDifficultyChecked, undefinedDifficultyChecked)
            .map { easy, medium, hard, undefined -> [WordItem.WordDifficulty: Bool] in
                let notChecked = (!easy && !medium && !hard && !undefined)
                let filterMap: [WordItem.WordDifficulty: Bool]
                if notChecked {
                    filterMap = [
                        .easy: true,
                        .medium: true,
                        .hard: true,
                        .undefined: true
                    ]
                } else {
                    filterMap = [
                        .easy: easy,
                        .medium: medium,
                        .hard: hard,
                        .undefined: undefined
                    ]
                }
                return filterMap
            }.bind(to: filterWordsMap)
            .disposed(by: disposeBag)
        
        filterWordsMap
            .subscribe(onNext: { _ in
                self.fetchWordItemsWithoutSync()
            }).disposed(by: disposeBag)
    }
    
    private func bindFilterWordsBySearchedText() {
        wordToSearch
            .subscribe(onNext: { _ in
                self.fetchWordItemsWithoutSync()
            }).disposed(by: disposeBag)
    }
    
    private func bindMinIntervalTimer() {
        intervalMinTimer
            .subscribe(onNext: { _ in
                self.fetchLatestSyncTime()
            }).disposed(by: disposeBag)
    }
    
    private func bindInputTagText() {
        tagText
            .filter { $0.contains(",") }
            .map { $0.split(separator: ",") }
            .map { $0.map { String($0) } }
            .map { $0.map { TagItemCellViewModel(tagItem: TagItem(title: $0), deletable: true, selectable: false) } }
            .flatMapLatest { cellViewModels -> Observable<[TagItemCellViewModel]> in
                cellViewModels.forEach {
                    $0.deleteRequested
                        .subscribe(onNext: { cellViewModel in
                            self.removeTag(to: cellViewModel)
                        }).disposed(by: self.disposeBag)
                }
                return .just(cellViewModels)
            }.map { self.wordTags.value + $0 }
            .do(onNext: { _ in
                self.clearInputTagText()
            }).bind(to: wordTags)
            .disposed(by: disposeBag)
    }
    
    private func bindWordItemsCountChanged() {
        wordItems
            .map { $0.count }
            .distinctUntilChanged()
            .subscribe(onNext: { _ in
                self.editWordIndex = nil
            }).disposed(by: disposeBag)
    }
}
