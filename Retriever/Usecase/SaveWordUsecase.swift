//
//  SaveWordUsecase.swift
//  Retriever
//
//  Created by thekan on 28/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift

class SaveWordUsecase {
    let wordRepository: WordRepositoryProtocol
    
    init(_ wordRepository: WordRepositoryProtocol) {
        self.wordRepository = wordRepository
    }
    
    func execute(with wordItem: WordItem) -> Observable<WordItem> {
        return wordRepository.save(wordItem: wordItem)
    }
}
