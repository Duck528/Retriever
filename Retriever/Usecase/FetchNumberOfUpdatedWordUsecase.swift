//
//  FetchNumberOfUpdatedWordUsecase.swift
//  Retriever
//
//  Created by thekan on 01/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift

class FetchNumberOfUpdatedWordUsecase {
    let wordItemDAO: RMWordItemDAO
    
    init(wordItemDAO: RMWordItemDAO) {
        self.wordItemDAO = wordItemDAO
    }
    
    func execute() -> Observable<Int> {
        return wordItemDAO
            .finds(filter: { $0.status == WordItem.WordStatus.updated.rawValue })
            .map { $0.count }
    }
}

