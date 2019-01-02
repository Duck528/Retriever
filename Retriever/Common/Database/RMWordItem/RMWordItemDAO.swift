//
//  RMWordItemDAO.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Realm
import RxSwift
import RealmSwift
import Foundation

class RMWordItemDAO: BaseDAO {
    typealias ModelType = RMWordItem
    
    class PairID {
        let recordID: String
        let localID: String
        
        init(recordID: String, localID: String) {
            self.recordID = recordID
            self.localID = localID
        }
    }
    
    func retriveRecordID(by wordItemID: String) -> Observable<String> {
        return find(by: wordItemID)
            .filterOptional()
            .map { $0.recordName }
    }
    
    func fetchWords(by recordIDs: [String]) -> Observable<[RMWordItem]> {
        return findAll()
            .map { $0.filter { recordIDs.contains($0.recordName) } }
    }
    
    func fetchDeletedWords() -> Observable<[RMWordItem]> {
        return finds(filter: { $0.status != WordItem.WordStatus.deleted.rawValue })
    }
    
    func deletes(by recordIDs: [String]) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let wordsToDelete = realm.objects(RMWordItem.self)
                    .filter { recordIDs.contains($0.recordName) }
                try realm.write {
                    realm.delete(wordsToDelete)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func deletes(localIDs: [String]) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let wordsToDelete = realm.objects(RMWordItem.self)
                    .filter { localIDs.contains($0.id) }
                try realm.write {
                    realm.delete(wordsToDelete)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
}
