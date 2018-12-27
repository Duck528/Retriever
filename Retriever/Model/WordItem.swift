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
    
    enum WordDifficulty: Int {
        case easy, medium, hard, undefined
        
        static func parse(int: Int) -> WordDifficulty {
            if int == 0 {
                return .easy
            } else if int == 1 {
                return .medium
            } else if int == 2 {
                return .hard
            } else {
                return .undefined
            }
        }
    }
    
    var word: String = ""
    var mean: String = ""
    var additionalInfo: String = ""
    var tags: [TagItem] = []
    var difficulty: WordDifficulty = .undefined
    
    init(word: String, mean: String, additionalInfo: String = "", tags: [TagItem] = [], difficulty: WordDifficulty = .undefined) {
        self.word = word
        self.mean = mean
        self.additionalInfo = additionalInfo
        self.tags = tags
        self.difficulty = difficulty
    }
    
    convenience init(word: String, mean: String, additionalInfo: String = "", tags: [TagItem] = [], difficulty: Int = WordDifficulty.undefined.rawValue) {
        let wordDifficulty = WordDifficulty.parse(int: difficulty)
        self.init(word: word, mean: mean, additionalInfo: additionalInfo, tags: tags, difficulty: wordDifficulty)
    }
    
    convenience init?(record: CKRecord) {
        guard let word = record["word"] as? String, let mean = record["mean"] as? String else {
            return nil
        }
        let additionalInfo = (record["additionalInfo"] as? String) ?? ""
        let tags = (record["tags"] as? [String]) ?? []
        let difficulty = (record["difficulty"] as? Int) ?? WordDifficulty.undefined.rawValue
        let tagItems = tags
            .map { TagItem(title: $0) }
        self.init(word: word, mean: mean, additionalInfo: additionalInfo, tags: tagItems, difficulty: difficulty)
    }
}
