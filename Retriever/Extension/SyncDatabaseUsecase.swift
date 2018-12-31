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
    
    private let disposeBag = DisposeBag()
    
    init(wordRepository: WordRepositoryProtocol, wordDAO: RMWordItemDAO) {
        self.wordRepository = wordRepository
        self.wordDAO = wordDAO
    }
    
    func execute() -> Completable {
        let fetchRemoteWordItemsObs = wordRepository.fetchWords()
        let fetchLocalWordItemsObs = wordDAO.findAll()
        
        Observable.zip(fetchRemoteWordItemsObs, fetchLocalWordItemsObs)
            .subscribe(onNext: { iCloudWordItems, rmWordItems in
                
            }).disposed(by: disposeBag)
        
        
    }
}
