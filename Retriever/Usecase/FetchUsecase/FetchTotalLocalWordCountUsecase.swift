//
//  FetchTotalLocalWordCountUsecase.swift
//  Retriever
//
//  Created by thekan on 28/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import RxSwift

class FetchTotalLocalWordCountUsecase {
    let wordItemDAO: RMWordItemDAO
    
    init(wordItemDAO: RMWordItemDAO) {
        self.wordItemDAO = wordItemDAO
    }
    
    func execute() -> Observable<Int> {
        return wordItemDAO.findAll()
            .map { $0.count }
    }
}
