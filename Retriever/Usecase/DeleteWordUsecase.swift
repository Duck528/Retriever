//
//  DeleteWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift

class DeleteWordUsecase {
    let wordItemDAO: RMWordItemDAO
    let wordRepository: WordICloudRepository
    
    init(wordItemDAO: RMWordItemDAO, wordRepository: WordICloudRepository) {
        self.wordItemDAO = wordItemDAO
        self.wordRepository = wordRepository
    }
    
//    func execute(wordItem: WordItem) -> Completable {
//        
//    }
//    
    private func updateLocalWordStatusToDeleted(_ wordItem: WordItem) -> Completable {
        let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .deleted)
        return wordItemDAO.update(rmWordItem)
            .ignoreElements()
    }
    
    private func deleteLocalWordItem(_ wordItem: WordItem) -> Completable {
        return wordItemDAO.delete(by: wordItem.id)
            .ignoreElements()
    }
    
    private func deleteRemoteWordItem(_ wordItem: WordItem) -> Completable {
        return wordItemDAO.retriveRecordID(by: wordItem.id)
            .flatMapLatest { recordID -> Observable<String> in
                self.wordRepository.delete(recordID: recordID)
            }.ignoreElements()
    }
}
