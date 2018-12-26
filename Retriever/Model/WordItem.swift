//
//  Word.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import CloudKit

class WordItem {
    var origin: String = ""
    var translate: String = ""
    var additionalInfo: String = ""
    var tags: [TagItem] = []
    
    convenience init?(record: CKRecord) {
        guard
            let origin = record["origin"] as? String,
            let translate = record["translate"] as? String,
            let additionalInfo = record["additionalInfo"] as? String,
            let tags = record["tags"] as? [String] else {
                return nil
        }
        self.init()
        self.origin = origin
        self.translate = translate
        self.additionalInfo = additionalInfo
        self.tags = tags
            .map { TagItem(title: $0) }
    }
}
