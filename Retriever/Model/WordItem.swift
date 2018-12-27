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
    
    init(word: String, mean: String, additionalInfo: String = "", tags: [TagItem] = []) {
        self.word = word
        self.mean = mean
        self.additionalInfo = additionalInfo
        self.tags = tags
    }
    
    convenience init?(record: CKRecord) {
        guard let word = record["word"] as? String, let mean = record["mean"] as? String else {
            return nil
        }
        let additionalInfo = (record["additionalInfo"] as? String) ?? ""
        let tags = (record["tags"] as? [String]) ?? []
        let tagItems = tags
            .map { TagItem(title: $0) }
        self.init(word: word, mean: mean, additionalInfo: additionalInfo, tags: tagItems)
    }
}
