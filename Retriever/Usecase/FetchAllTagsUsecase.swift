//
//  FetchAllTagsUsecase.swift
//  Retriever
//
//  Created by thekan on 07/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift

class FetchAllTagsUsecase {
    let wordItemDAO: RMWordItemDAO
    
    init(wordItemDAO: RMWordItemDAO) {
        self.wordItemDAO = wordItemDAO
    }
    
    func execute() -> Observable<[TagItem]> {
        return wordItemDAO.findAll()
            .map { $0.flatMap { $0.toWordItem().tags } }
            .filter { $0.count > 0 }
    }
}
