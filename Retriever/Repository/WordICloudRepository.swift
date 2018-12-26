//
//  WordICloudRepository.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift
import RxCocoa
import CloudKit

class WordICloudRepository {
    private let wordType = "Word"
    
    func fetchWords() -> Observable<[WordItem]> {
        let allPredicate = NSPredicate(format: "")
        let query = CKQuery(recordType: wordType, predicate: allPredicate)
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase

        return Observable.create { observer in
            privateDB.perform(query, inZoneWith: nil) { results, error in
                if let error = error {
                    observer.onError(error)
                }
                privateDB.perform(query, inZoneWith: nil) { results, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let words = (results ?? [])
                        .compactMap { WordItem(record: $0) }
                    observer.onNext(words)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
}
