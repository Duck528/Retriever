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

class WordICloudRepository: WordRepositoryProtocol {
    
    enum Errors: Error {
        case recordNotFound
        case recordIDNotFound
    }
    
    private let wordType = "WordItem"
    
    private let container: CKContainer
    private let privateDB: CKDatabase
    private var cachedRecordID: CKRecord.ID?
    
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
                let words = (results ?? [])
                    .compactMap { ICloudWordItem(record: $0) }
                    .map { $0.toWordItem() }
                observer.onNext(words)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    func save(wordItem: WordItem) -> Observable<WordItem> {
        return fetchUserICloudID()
            .flatMapLatest { userId -> Observable<CKRecord> in
                let record = self.configureWordRecord(userID: userId, wordItem: wordItem)
                return Observable.of(record)
            }
            .flatMapLatest { record -> Observable<WordItem> in
                self.updateRecord(record)
            }
    }
}

extension WordICloudRepository {
    private func updateRecord(_ record: CKRecord) -> Observable<WordItem> {
        return Observable.create { observer in
            self.privateDB.save(record) { record, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                if let record = record, let iCloudWordItem = ICloudWordItem(record: record) {
                    observer.onNext(iCloudWordItem.toWordItem())
                    observer.onCompleted()
                } else {
                    observer.onError(Errors.recordNotFound)
                }
            }
            return Disposables.create()
        }
    }
    
    private func configureWordRecord(userID: String, wordItem: WordItem) -> CKRecord {
        let wordRecord = CKRecord(recordType: wordType)
        wordRecord.setValue(userID, forKey: "userID")
        wordRecord.setValue(wordItem.word, forKey: "word")
        wordRecord.setValue(wordItem.mean, forKey: "mean")
        wordRecord.setValue(wordItem.additionalInfo, forKey: "additionalInfo")
        wordRecord.setValue(wordItem.tags.map { $0.title }, forKey: "tags")
        wordRecord.setValue(wordItem.difficulty.rawValue, forKey: "difficulty")
        return wordRecord
    }
    
    private func fetchUserICloudID() -> Observable<String> {
        return Observable.create { observer in
            if let cachedRecordID = self.cachedRecordID {
                observer.onNext(cachedRecordID.recordName)
                observer.onCompleted()
            } else {
                self.container.fetchUserRecordID { recordID, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    if let recordID = recordID {
                        self.cachedRecordID = recordID
                        observer.onNext(recordID.recordName)
                        observer.onCompleted()
                    } else {
                        observer.onError(Errors.recordIDNotFound)
                    }
                }
            }
            return Disposables.create()
        }
    }
}
