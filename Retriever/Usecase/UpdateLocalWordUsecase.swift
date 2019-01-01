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
        let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .updated)
        rmWordItem.lastModified = Date()
        return wordDAO.update(rmWordItem)
            .map { $0.toWordItem() }
    }
}
