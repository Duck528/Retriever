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
        
        return Observable.zip(fetchRemoteWordItemsObs, fetchLocalWordItemsObs)
            .flatMapLatest { remoteWordItems, localWordItems -> Observable<[ICloudWordItem]> in
                var notSyncedWordItems: [ICloudWordItem] = remoteWordItems
                for localWordItem in localWordItems {
                    if let index = notSyncedWordItems.firstIndex(where: { $0.recordName == localWordItem.recordName }) {
                        notSyncedWordItems.remove(at: index)
                    }
                }
                return .just(notSyncedWordItems)
            }
            .map { $0.map { RMWordItem(iCloudWordItem: $0) } }
            .flatMapLatest { self.wordDAO.insert($0) }
            .ignoreElements()
    }
}
