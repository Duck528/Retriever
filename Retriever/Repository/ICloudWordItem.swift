//
//  ICloudWordItem.swift
//  Retriever
//
//  Created by thekan on 29/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import CloudKit

class ICloudWordItem {
    let userID: String
    let recordName: String
    let lastModified: Date
    var word: String = ""
    var mean: String = ""
    var additionalInfo: String = ""
    var tags: [String] = []
    var difficulty: Int
    
    init?(record: CKRecord) {
        guard
            let userID = record["userID"] as? String,
            let word = record["word"] as? String,
            let lastModified = record.modificationDate,
            let mean = record["mean"] as? String else {
                return nil
        }
        let additionalInfo = (record["additionalInfo"] as? String) ?? ""
        let tags = (record["tags"] as? [String]) ?? []
        let difficulty = (record["difficulty"] as? Int) ?? 3
        
        self.userID = userID
        self.recordName = record.recordID.recordName
        self.lastModified = lastModified
        self.word = word
        self.mean = mean
        self.additionalInfo = additionalInfo
        self.tags = tags
        self.difficulty = difficulty
    }
    
    func toWordItem() -> WordItem {
        let tagItems = tags.map { TagItem(title: $0) }
        let wordItem = WordItem(
            word: word,
            mean: mean,
            additionalInfo: additionalInfo,
            tags: tagItems,
            difficulty: difficulty)
        return wordItem
    }
}
