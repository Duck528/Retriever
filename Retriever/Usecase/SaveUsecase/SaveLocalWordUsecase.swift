//
//  SaveLocalWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift

class SaveLocalWordUsecase {
    let wordItemDAO: RMWordItemDAO
    
    init(wordItemDAO: RMWordItemDAO) {
        self.wordItemDAO = wordItemDAO
    }
    
    func execute(wordItem: WordItem) -> Observable<WordItem> {
        let rmWordItem = RMWordItem(wordItem: wordItem, wordStatus: .updated)
        return wordItemDAO.insert(rmWordItem)
            .map { $0.toWordItem() }
    }
}
