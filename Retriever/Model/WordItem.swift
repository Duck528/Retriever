//
//  WordItem.swift
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
    let lastModified: Date
    var additionalInfo: String = ""
    var tags: [TagItem] = []
    var difficulty: WordDifficulty = .undefined
    
    init(word: String, mean: String, lastModified: Date, additionalInfo: String = "", tags: [TagItem] = [], difficulty: WordDifficulty = .undefined) {
        self.word = word
        self.mean = mean
        self.lastModified = lastModified
        self.additionalInfo = additionalInfo
        self.tags = tags
        self.difficulty = difficulty
    }
    
    convenience init(word: String, mean: String, lastModified: Date, additionalInfo: String = "", tags: [TagItem] = [],
                     difficulty: Int = WordDifficulty.undefined.rawValue) {
        let wordDifficulty = WordDifficulty.parse(int: difficulty)
        self.init(word: word, mean: mean, lastModified: lastModified, additionalInfo: additionalInfo, tags: tags, difficulty: wordDifficulty)
    }
}
