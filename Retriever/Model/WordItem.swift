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
    var word: String = ""
    var mean: String = ""
    var additionalInfo: String = ""
    var tags: [TagItem] = []
    
    convenience init?(record: CKRecord) {
        guard
            let word = record["word"] as? String,
            let mean = record["mean"] as? String,
            let additionalInfo = record["additionalInfo"] as? String,
            let tags = record["tags"] as? [String] else {
                return nil
        }
        self.init()
        self.word = word
        self.mean = mean
        self.additionalInfo = additionalInfo
        self.tags = tags
            .map { TagItem(title: $0) }
    }
}
