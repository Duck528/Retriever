//
//  SyncDatabaseUsecase.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift

class SyncDatabaseUsecase {
    let wordRepository: WordRepositoryProtocol
    let wordDAO: RMWordItemDAO
    
    init(wordRepository: WordRepositoryProtocol, wordDAO: RMWordItemDAO) {
        self.wordRepository = wordRepository
        self.wordDAO = wordDAO
    }
    
//    func execute() -> Completable {
//        wordRepository.fetchWords()
//    }
}
