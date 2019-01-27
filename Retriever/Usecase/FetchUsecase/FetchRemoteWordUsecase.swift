//
//  FetchRemoteWordUsecase.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift

class FetchRemoteWordUsecase {
    let wordRepository: WordRepositoryProtocol
    
    init(_ wordRepository: WordRepositoryProtocol) {
        self.wordRepository = wordRepository
    }
    
    func execute() -> Observable<[WordItem]> {
        return wordRepository.fetchWords()
            .map { $0.map { $0.toWordItem() } }
    }
}
