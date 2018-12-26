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
    
    enum Errors: Error {
        case recordNotFound
    }
    
    private let wordType = "Word"
    
    private let container: CKContainer
    private let privateDB: CKDatabase
    
    init() {
        container = CKContainer.default()
        privateDB = container.privateCloudDatabase
    }
    
    func fetchWords() -> Observable<[WordItem]> {
        let allPredicate = NSPredicate(value: true)
        let query = CKQuery(recordType: wordType, predicate: allPredicate)

        return Observable.create { observer in
            self.privateDB.perform(query, inZoneWith: nil) { results, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                self.privateDB.perform(query, inZoneWith: nil) { results, error in
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
    
    func save(wordItem: WordItem) -> Observable<WordItem> {
        let wordRecord = CKRecord(recordType: wordType)
        wordRecord.setValue(wordItem.origin, forKey: "")
        wordRecord.setValue(wordItem.translate, forKey: "")
        wordRecord.setValue(wordItem.additionalInfo, forKey: "")
        wordRecord.setValue(wordItem.tags, forKey: "")
        
        return Observable.create { observer in
            self.privateDB.save(wordRecord) { record, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                if let record = record, let wordItem = WordItem(record: record) {
                    observer.onNext(wordItem)
                } else {
                    observer.onError(Errors.recordNotFound)
                }
            }
            return Disposables.create()
        }
    }
}
