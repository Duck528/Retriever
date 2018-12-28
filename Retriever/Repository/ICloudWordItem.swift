//
//  ICloudWordItem.swift
//  Retriever
//
//  Created by thekan on 29/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation

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
}
