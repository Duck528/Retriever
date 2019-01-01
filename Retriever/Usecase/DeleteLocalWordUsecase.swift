//
//  DeleteWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

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
                    let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .deleted)
                    return self.wordItemDAO.update(rmWordItem)
                        .map { _ in }
                } else {
                    return self.wordItemDAO.delete(by: wordItem.id)
                }
            }.ignoreElements()
    }

    private func updateLocalWordStatusToDeleted(_ wordItem: WordItem) -> Completable {
        let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .deleted)
        return wordItemDAO.update(rmWordItem)
            .ignoreElements()
    }
    
    private func deleteLocalWordItem(_ wordItem: WordItem) -> Completable {
        return wordItemDAO.delete(by: wordItem.id)
            .ignoreElements()
    }
}
