//
//  WordRepositoryProtocol.swift
//  Retriever
//
//  Created by thekan on 28/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift

protocol WordRepositoryProtocol {
    func fetchWords() -> Observable<[WordItem]>
    func save(wordItem: WordItem) -> Observable<WordItem>
}
