//
//  RMWordItemDAO.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RxSwift

class RMWordItemDAO: BaseDAO {
    typealias ModelType = RMWordItem
    
    func retriveRecordID(by wordItemID: String) -> Observable<String> {
        return find(by: wordItemID)
            .filterOptional()
            .map { $0.recordName }
    }
    
    func fetchDeletedWords() -> Observable<[RMWordItem]> {
        return finds(filter: { $0.status != WordItem.WordStatus.deleted.rawValue })
    }
}
