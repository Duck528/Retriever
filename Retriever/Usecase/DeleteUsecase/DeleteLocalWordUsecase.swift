//
//  DeleteWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import Foundation
import RxSwift

class DeleteLocalWordUsecase {
    let wordItemDAO: RMWordItemDAO
    
    init(wordItemDAO: RMWordItemDAO) {
        self.wordItemDAO = wordItemDAO
    }
    
    func execute(wordItem: WordItem) -> Completable {
        return wordItemDAO.find(by: wordItem.id)
            .filterOptional()
            .map { !$0.recordName.isEmpty }
            .flatMapLatest { hasRecordName -> Observable<Void> in
                if hasRecordName {
                    return self.updateLocalWordStatusToDeleted(wordItem)
                } else {
                    return self.deleteLocalWordItem(wordItem)
                }
            }.ignoreElements()
    }

    private func updateLocalWordStatusToDeleted(_ wordItem: WordItem) -> Observable<Void> {
        return wordItemDAO.retriveRecordID(by: wordItem.id)
            .flatMapLatest { recordID -> Observable<RMWordItem> in
                let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .deleted)
                rmWordItem.recordName = recordID
                rmWordItem.lastModified = Date()
                return .just(rmWordItem)
            }.flatMapLatest { self.wordItemDAO.update($0) }
            .map { _ in }
    }
    
    private func deleteLocalWordItem(_ wordItem: WordItem) -> Observable<Void> {
        return wordItemDAO.delete(by: wordItem.id)
    }
}
