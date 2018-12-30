//
//  RMWordItem.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RealmSwift

class RMWordItem: Object, Storable {
    typealias PrimaryKeyType = String
    typealias ConvertType = WordItem
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var recordName: String = ""
    @objc dynamic var word: String = ""
    @objc dynamic var mean: String = ""
    @objc dynamic var tags: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var additionalInfo: String = ""
    @objc dynamic var difficulty: Int = 3
    
    var primaryKey: String {
        return id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(iCloudWordItem: ICloudWordItem) {
        self.init()
        recordName = iCloudWordItem.recordName
        word = iCloudWordItem.word
        mean = iCloudWordItem.mean
        tags = convertTagsToCSVFormatString(iCloudWordItem.tags)
        lastModified = iCloudWordItem.lastModified
        additionalInfo = iCloudWordItem.additionalInfo
        difficulty = iCloudWordItem.difficulty
    }
    
    func convert() -> WordItem {
        let wordItem = WordItem(
            word: word,
            mean: mean,
            lastModified: lastModified,
            additionalInfo: additionalInfo,
            tags: parseTags(tags),
            difficulty: difficulty)
        return wordItem
    }
}

extension RMWordItem {
    private func parseTags(_ tags: String) -> [TagItem] {
        return []
    }
    
    private func convertTagsToCSVFormatString(_ tags: [String]) -> String {
        return ""
    }
}
