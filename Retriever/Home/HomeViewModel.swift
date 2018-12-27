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
    }
    
    let wordToSearch = BehaviorRelay<String>(value: "")
    let allTags = BehaviorRelay<[TagItemCellViewModel]>(value: [])
    let viewAction = PublishSubject<ViewAction>()
    
    let fetchTagUsecase: FetchTagUsecase
    let disposeBag = DisposeBag()
    
    init() {
        fetchTagUsecase = Assembler().resolve()
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
}
