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
    let filteredWords = BehaviorRelay<[WordItem]>(value: [])
    let totalNumberOfWord = BehaviorRelay<Int>(value: 0)

    let tags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    
    let filterWordsMap = BehaviorRelay<[WordItem.WordDifficulty: Bool]>(value: [:])
    
    let easyLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let mediumLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let hardLevelFilterOn = BehaviorRelay<Bool>(value: false)
    let undefinedLevelFilterOn = BehaviorRelay<Bool>(value: false)
    
    private let fetchLocalWordUsecase: FetchLocalWordUsecase
    private let fetchLocalTagUsecase: FetchAllLocalTagsUsecase
    private let fetchTotalWordCountUsecase: FetchTotalLocalWordCountUsecase
    private let disposeBag = DisposeBag()
    
    init() {
        fetchLocalWordUsecase = Assembler().resolve()
        fetchLocalTagUsecase = Assembler().resolve()
        fetchTotalWordCountUsecase = Assembler().resolve()
        
        bindWordLevelToWordFilterMap()
        
        fetchTotalNumberOfWord()
        fetchAllLocalTag()
        fetchLocalWordByFilter()
    }
}

extension QuizeViewModel {
    private func fetchLocalWordByFilter() {
        let selectedTags = tags.value
            .filter { $0.selected.value }
            .map { $0.tagItem.value }
        let filterMap = filterWordsMap.value
        
        fetchLocalWordUsecase.execute()
            .map { self.filterWordItemsByTags(wordItems: $0, tags: selectedTags) }
            .map { wordItems in wordItems.filter { filterMap[$0.difficulty].value ?? false } }
            .bind(to: filteredWords)
            .disposed(by: disposeBag)
    }
    
    private func fetchTotalNumberOfWord() {
        fetchTotalWordCountUsecase.execute()
            .bind(to: totalNumberOfWord)
            .disposed(by: disposeBag)
    }
    
    private func fetchAllLocalTag() {
        fetchLocalTagUsecase.execute()
            .map { $0.map { TagItemCellViewModel(tagItem: $0, selectable: true) } }
            .flatMapLatest { tagItems -> Observable<[TagItemCellViewModel]> in
                for tag in tagItems {
                    tag.selected
                        .subscribe(onNext: { selected in
                            self.fetchLocalWordByFilter()
                        }).disposed(by: self.disposeBag)
                }
                return .just(tagItems)
            }.bind(to: tags)
            .disposed(by: disposeBag)
    }
    
    private func bindWordLevelToWordFilterMap() {
        Observable
            .combineLatest(easyLevelFilterOn, mediumLevelFilterOn, hardLevelFilterOn, undefinedLevelFilterOn)
            .do(onNext: { print("\($0), \($1), \($2), \($3)") })
            .map { easyOn, mediumOn, hardOn, undefinedOn -> [WordItem.WordDifficulty: Bool] in
                return [
                    .easy: easyOn,
                    .medium: mediumOn,
                    .hard: hardOn,
                    .undefined: undefinedOn
                ]
            }.bind(to: filterWordsMap)
            .disposed(by: disposeBag)
    }
    
    private func filterWordItemsByTags(wordItems: [WordItem], tags: [TagItem]) -> [WordItem] {
        guard tags.count > 0 else {
            return wordItems
        }
        
        var mutableWordItems: [WordItem] = []
        for wordItem in wordItems {
            let wordTags = wordItem.tags
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
