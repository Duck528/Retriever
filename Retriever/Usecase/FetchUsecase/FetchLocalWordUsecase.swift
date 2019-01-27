//
//  FetchLocalWordUsecase.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift

class FetchLocalWordUsecase {
    let wordDAO: RMWordItemDAO
    
    init(wordDAO: RMWordItemDAO) {
        self.wordDAO = wordDAO
    }
    
    func execute() -> Observable<[WordItem]> {
        return wordDAO.fetchDeletedWords()
            .map { $0.map { $0.toWordItem() } }
    }
}
