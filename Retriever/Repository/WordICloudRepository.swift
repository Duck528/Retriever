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
    
    func fetchWords() -> Observable<[WordItem]> {
        let allPredicate = NSPredicate(format: "")
        let query = CKQuery(recordType: "", predicate: allPredicate)
        let container = CKContainer.default()
        let privateDB = container.privateCloudDatabase

        return Observable.create { observer in
            privateDB.perform(query, inZoneWith: nil) { results, error in
                if let error = error {
                    observer.onError(error)
                }
                
            }
            return Disposables.create()
        }
//
//        privateDB.perform(query, inZoneWith: nil) { results, error in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//
//
//        }
    }
}
