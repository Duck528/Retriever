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
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    let viewAction = PublishSubject<ViewAction>()
    
    let wordText = BehaviorRelay<String>(value: "")
    let meanText = BehaviorRelay<String>(value: "")
    let additionalInfoText = BehaviorRelay<String>(value: "")
    
    var wordAppendable: Observable<Bool> {
        let hasWordObs = wordText.asObservable()
            .map { !$0.isEmpty }
        let hasMeanObs = meanText.asObservable()
            .map { !$0.isEmpty }
        
        return Observable.combineLatest(hasWordObs, hasMeanObs)
            .map { $0 && $1 }
    }
    
    let fetchTagUsecase: FetchTagUsecase
    let saveWordUsecase: SaveWordUsecase
    let disposeBag = DisposeBag()
    
    init() {
        fetchTagUsecase = Assembler().resolve()
        saveWordUsecase = Assembler().resolve()
        fetchTagItems()
    }
    
    private func fetchTagItems() {
        fetchTagUsecase.execute()
            .map { $0.map { TagItemCellViewModel(tagItem: $0) } }
            .bind(to: allTags)
            .disposed(by: disposeBag)
    }
    
    func cancelAppendWordButtonTapped() {
        viewAction.onNext(.hideAppendWordSection)
    }
    
    func presentAppendWordButtonTapped() {
        viewAction.onNext(.showAppendWordSection)
    }
    
    func saveWordButtonTapped(with wordItem: WordItem) {
        saveWordUsecase.execute(with: wordItem)
            .subscribe(onNext: { savedWordItem in
                print(savedWordItem)
            }).disposed(by: disposeBag)
    }
    
    func saveWordContinouslyButtonTapped(with wordItem: WordItem) {
        saveWordUsecase.execute(with: wordItem)
            .subscribe(onNext: { savedWordItem in
                print(savedWordItem)
            }).disposed(by: disposeBag)
    }
}
