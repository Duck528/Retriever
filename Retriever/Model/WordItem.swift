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
            if int == WordDifficulty.easy.rawValue {
                return .easy
            } else if int == WordDifficulty.medium.rawValue {
                return .medium
            } else if int == WordDifficulty.hard.rawValue {
                return .hard
            } else {
                return .undefined
            }
        }
        
        var title: String {
            switch self {
            case .easy: return "쉬움"
            case .medium: return "보통"
            case .hard: return "어려움"
            case .undefined: return "정의되지 않음"
            }
        }
    }
    
    enum WordStatus: Int {
        case updated
        case deleted
        case stable
        
        static func parse(int: Int) -> WordStatus {
            if int == WordStatus.updated.rawValue {
                return .updated
            } else if int == WordStatus.deleted.rawValue {
                return .deleted
            } else {
                return .stable
            }
        }
    }
    
    let id: String
    let recordName: String?
    var word: String = ""
    var mean: String = ""
    let lastModified: Date
    var additionalInfo: String = ""
    var tags: [TagItem] = []
    var difficulty: WordDifficulty = .undefined
    var status: WordStatus = .stable
    
    init(id: String = UUID().uuidString, recordName: String? = nil, word: String, mean: String, lastModified: Date, additionalInfo: String = "",
         tags: [TagItem] = [], difficulty: WordDifficulty = .undefined, status: WordStatus = .stable) {
        self.id = id
        self.recordName = recordName
        self.word = word
        self.mean = mean
        self.lastModified = lastModified
        self.additionalInfo = additionalInfo
        self.tags = tags
        self.difficulty = difficulty
        self.status = status
    }
    
    convenience init(id: String = UUID().uuidString, recordName: String? = nil, word: String, mean: String,
                     lastModified: Date, additionalInfo: String = "", tags: [TagItem] = [],
                     difficulty: Int = WordDifficulty.undefined.rawValue) {
        let wordDifficulty = WordDifficulty.parse(int: difficulty)
        self.init(
            id: id,
            recordName: recordName,
            word: word,
            mean: mean,
            lastModified: lastModified,
            additionalInfo: additionalInfo,
            tags: tags,
            difficulty: wordDifficulty)
    }
}
