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
        let fetchAllLocalWordsObs = wordDAO.findAll()
            .share()
        
        let fetchRemoteWordsToSaveLocal = Observable
            .zip(wordRepository.fetchWords(), fetchAllLocalWordsObs)
            .flatMapLatest { remoteWords, localWords -> Observable<[RMWordItem]> in
                var wordsToSaveLocal: [RMWordItem] = []
                for remoteWord in remoteWords {
                    if let index = localWords.firstIndex(where: { $0.recordName == remoteWord.recordName }) {
                        let localID = localWords[index].id
                        wordsToSaveLocal.append(RMWordItem(iCloudWordItem: remoteWord, localID: localID))
                    } else {
                        wordsToSaveLocal.append(RMWordItem(iCloudWordItem: remoteWord))
                    }
                }
                return .just(wordsToSaveLocal)
            }
            .flatMapLatest { self.wordDAO.updateOrCreate(array: $0) }
        
        let fetchLocalWordsToSaveRemote = fetchAllLocalWordsObs
            .map { $0.filter { $0.recordName.isEmpty || $0.status == WordItem.WordStatus.updated.rawValue  } }
            .map { $0.map { $0.toWordItem() } }
        let fetchLocalWordsToDeleteRemote = fetchAllLocalWordsObs
            .map { $0.filter { $0.status == WordItem.WordStatus.deleted.rawValue} }
            .map { $0.map { $0.toWordItem() } }
            
        return Observable.zip(fetchLocalWordsToSaveRemote, fetchLocalWordsToDeleteRemote)
            .flatMapLatest { localWordsToSaveRemote, localWordsToDeleteRemote -> Observable<Void> in
                self.wordRepository
                    .updateMultiple(wordsToSave: localWordsToSaveRemote, wordsToDelete: localWordsToDeleteRemote)
            }.flatMapLatest { _ -> Observable<Void> in
                self.wordDAO
                    .deletes(filter: { $0.status == WordItem.WordStatus.deleted.rawValue })
            }.flatMapLatest { _ -> Observable<Void> in
                self.wordDAO
                    .updateAllWordsToStableStatus()
            }.flatMapLatest { _ -> Observable<Void> in
                fetchRemoteWordsToSaveLocal
            }.ignoreElements()
    }
}
