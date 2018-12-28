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
    var word: String = ""
    var mean: String = ""
    var additionalInfo: String = ""
    var tags: [String] = []
    var difficulty: Int
    
    init(userID: String, wordItem: WordItem) {
        self.userID = userID
        self.word = wordItem.word
        self.mean = wordItem.mean
        self.additionalInfo = wordItem.additionalInfo
        self.tags = wordItem.tags
            .map { $0.title }
        self.difficulty = wordItem.difficulty.rawValue
    }
    
    init(userID: String, word: String, mean: String, additionalInfo: String, tags: [String], difficulty: Int) {
        self.userID = userID
        self.mean = mean
        self.additionalInfo = additionalInfo
        self.tags = tags
        self.difficulty = difficulty
    }
    
    convenience init?(record: CKRecord) {
        guard
            let userID = record["userID"] as? String,
            let word = record["word"] as? String,
            let mean = record["mean"] as? String else {
                return nil
        }
        let additionalInfo = (record["additionalInfo"] as? String) ?? ""
        let tags = (record["tags"] as? [String]) ?? []
        let difficulty = (record["difficulty"] as? Int) ?? 3
        self.init(userID: userID, word: word, mean: mean, additionalInfo: additionalInfo, tags: tags, difficulty: difficulty)
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
