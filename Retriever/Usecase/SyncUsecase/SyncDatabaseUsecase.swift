//
//  SyncDatabaseUsecase.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift
import CloudKit

class SyncDatabaseUsecase {
    
    private class OperationInfo {
        let wordsToSave: [RMWordItem]
        let wordsToDelete: [RMWordItem]
        
        init(wordsToSave: [RMWordItem], wordsToDelete: [RMWordItem]) {
            self.wordsToSave = wordsToSave
            self.wordsToDelete = wordsToDelete
        }
    }
    
    let wordRepository: WordRepositoryProtocol
    let wordDAO: RMWordItemDAO
    
    private let disposeBag = DisposeBag()
    
    init(wordRepository: WordRepositoryProtocol, wordDAO: RMWordItemDAO) {
        self.wordRepository = wordRepository
        self.wordDAO = wordDAO
    }
    
    func execute() -> Completable {
        let fetchLocalWordsToRemoteObs = wordDAO.findAll()
            .share()
        
        let filterLocalWordsToSaveObs = fetchLocalWordsToRemoteObs
            .map { $0.filter { $0.recordName.isEmpty || $0.status == WordItem.WordStatus.updated.rawValue } }
        
        let filterLocalWordsToDeleteObs = fetchLocalWordsToRemoteObs
            .map { $0.filter { $0.status == WordItem.WordStatus.deleted.rawValue} }
        
        let executeOperationObs = Observable
            .zip(filterLocalWordsToSaveObs, filterLocalWordsToDeleteObs)
            .map { OperationInfo(wordsToSave: $0, wordsToDelete: $1) }
            .flatMapLatest { operationInfo -> Observable<(OperationInfo, OperationResults)> in
                let wordsToSave = operationInfo.wordsToSave
                    .map { $0.toWordItem() }
                let wordsToDelete = operationInfo.wordsToDelete
                    .map { $0.toWordItem() }
                return self.wordRepository
                    .updateMultiple(wordsToSave: wordsToSave, wordsToDelete: wordsToDelete)
                    .flatMapLatest { operationResults -> Observable<(OperationInfo, OperationResults)> in
                        return .just((operationInfo, operationResults))
                    }
            }.share()
        
        let deleteDeletedWordsAfterOperationObs = executeOperationObs
            .map { $0.1.deletedRecordIDs.map { $0.recordName } }
            .flatMapLatest { self.wordDAO.deletes(by: $0) }
        
        let deleteAndInsertUpdatedWordsAfterOperationObs = executeOperationObs
            .map { ($0.0, $0.1.updatedRecords.compactMap { ICloudWordItem(record: $0) }) }
            .map { ($0.0.wordsToSave, $0.1.map { RMWordItem(iCloudWordItem: $0) }) }
            .do(onNext: { print("[Sync] wordsToSave count: \($0.0.count)") })
            .flatMapLatest { param -> Observable<[RMWordItem]> in
                let localIDsToDelete = param.0.map { $0.id }
                return self.wordDAO.deletes(localIDs: localIDsToDelete)
                    .map { _ in param.1 }
            }.flatMapLatest { self.wordDAO.insert($0) }
        
        let fetchRemoteNotSyncedWords = Observable
            .zip(wordRepository.fetchWords(), wordDAO.finds(filter: { !$0.recordName.isEmpty }))
            .flatMapLatest { remoteWords, localWords -> Observable<[RMWordItem]> in
                let localRecordIDs = localWords
                    .map { $0.recordName }
                let notSyncedRemoteWords = remoteWords
                    .filter { !localRecordIDs.contains($0.recordName) }
                    .compactMap { RMWordItem(iCloudWordItem: $0) }
                return .just(notSyncedRemoteWords)
            }
        
        return Observable.zip(deleteDeletedWordsAfterOperationObs, deleteAndInsertUpdatedWordsAfterOperationObs)
            .flatMapLatest { _, _ in fetchRemoteNotSyncedWords }
            .flatMap { self.wordDAO.insert($0) }
            .ignoreElements()
    }
}
