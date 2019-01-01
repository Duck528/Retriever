//
//  UpdateLocalWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import Foundation
import RxSwift

class UpdateLocalWordUsecase {
    let wordDAO: RMWordItemDAO
    
    init(wordDAO: RMWordItemDAO) {
        self.wordDAO = wordDAO
    }
    
    func execute(wordItem: WordItem) -> Observable<WordItem> {
        return wordDAO.retriveRecordID(by: wordItem.id)
            .flatMapLatest { recordID -> Observable<RMWordItem> in
                let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .updated)
                rmWordItem.recordName = recordID
                rmWordItem.lastModified = Date()
                return .just(rmWordItem)
            }.flatMapLatest { rmWordItem -> Observable<RMWordItem> in
                return self.wordDAO.update(rmWordItem)
            }.map { $0.toWordItem() }
    }
}
