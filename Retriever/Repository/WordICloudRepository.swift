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
    
    func fetchWords() -> Observable<[ICloudWordItem]> {
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
                self.uploadRecord(record)
            }
    }
    
    func updateMultiple(wordsToSave: [WordItem], wordsToDelete: [WordItem]) -> Observable<Void> {
        print("called")
        let mapRecordsToSaveObs = fetchUserICloudID()
            .flatMapLatest { userID -> Observable<[CKRecord]> in
                let recordsToSave = wordsToSave
                    .map { self.configureWordRecord(userID: userID, wordItem: $0) }
                return .just(recordsToSave)
            }
        let mapRecordsToDeleteObs = fetchUserICloudID()
            .flatMapLatest { userID -> Observable<[CKRecord.ID]> in
                let recordIDsToDelete = wordsToDelete
                    .map { self.configureWordRecord(userID: userID, wordItem: $0) }
                    .map { $0.recordID }
                return .just(recordIDsToDelete)
            }
        
        return Observable.zip(mapRecordsToSaveObs, mapRecordsToDeleteObs)
            .flatMapLatest { recordsToSave, recordIDsToDelete -> Observable<Void> in
                self.executeModifyOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
            }
    }
    
    private func executeModifyOperation(recordsToSave: [CKRecord], recordIDsToDelete: [CKRecord.ID]) -> Observable<Void> {
        return Observable.create { observer in
            let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
            operation.savePolicy = .changedKeys
            operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                    return
                } else {
                    print("saved: \(savedRecords?.count), deleted: \(deletedRecordIDs?.count)")
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            self.privateDB.add(operation)
            return Disposables.create()
        }
    }
    
    func updateMultiples() {
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: nil)
        privateDB.add(modifyOperation)
    }
    
    func delete(recordID: String) -> Observable<String> {
        let ckRecordID = CKRecord.ID(recordName: recordID)
        return deleteRecord(ckRecordID)
    }
}

extension WordICloudRepository {
    private func uploadRecord(_ record: CKRecord) -> Observable<WordItem> {
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
    
    private func deleteRecord(_ id: CKRecord.ID) -> Observable<String> {
        return Observable.create { observer in
            self.privateDB.delete(withRecordID: id) { recordID, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                if let recordID = recordID {
                    observer.onNext(recordID.recordName)
                    observer.onCompleted()
                } else {
                    observer.onError(Errors.recordIDNotFound)
                }
            }
            return Disposables.create()
        }
    }
    
    private func configureWordRecord(userID: String, wordItem: WordItem) -> CKRecord {
        let wordRecord: CKRecord
        if let recordName = wordItem.recordName {
            wordRecord = CKRecord(recordType: wordType, recordID: CKRecord.ID(recordName: recordName))
        } else {
            wordRecord = CKRecord(recordType: wordType)
        }
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
