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
    typealias ConvertType = RMWordItem
    
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var recordName: String = ""
    @objc dynamic var word: String = ""
    @objc dynamic var mean: String = ""
    @objc dynamic var tags: String = ""
    @objc dynamic var lastModified: Date = Date()
    @objc dynamic var additionalInfo: String = ""
    @objc dynamic var difficulty: Int = WordItem.WordDifficulty.undefined.rawValue
    @objc dynamic var status: Int = WordItem.WordStatus.stable.rawValue
    
    var primaryKey: String {
        return id
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(iCloudWordItem: ICloudWordItem, localID: String? = nil) {
        self.init()
        if let localID = localID {
            id = localID
        }
        recordName = iCloudWordItem.recordName
        word = iCloudWordItem.word
        mean = iCloudWordItem.mean
        tags = convertTagsToCSVFormatString(iCloudWordItem.tags)
        lastModified = iCloudWordItem.lastModified
        additionalInfo = iCloudWordItem.additionalInfo
        difficulty = iCloudWordItem.difficulty
    }
    
    convenience init(wordItem: WordItem, wordStatus: WordItem.WordStatus) {
        self.init()
        id = wordItem.id
        word = wordItem.word
        mean = wordItem.mean
        tags = convertTagsToCSVFormatString(wordItem.tags.map { $0.title })
        lastModified = wordItem.lastModified
        additionalInfo = wordItem.additionalInfo
        difficulty = wordItem.difficulty.rawValue
        status = wordStatus.rawValue
    }
    
    convenience init(id: String = UUID().uuidString, recordName: String, word: String,
                     mean: String, tags: String, lastModified: Date,
                     additionalInfo: String, difficulty: Int, status: Int = WordItem.WordStatus.stable.rawValue) {
        self.init()
        self.id = id
        self.recordName = recordName
        self.word = word
        self.mean = mean
        self.tags = tags
        self.lastModified = lastModified
        self.additionalInfo = additionalInfo
        self.difficulty = difficulty
        self.status = status
    }
    
    func convert() -> RMWordItem {
        let wordItem = RMWordItem(
            id: id,
            recordName: recordName,
            word: word,
            mean: mean,
            tags: tags,
            lastModified: lastModified,
            additionalInfo: additionalInfo,
            difficulty: difficulty,
            status: status)
        return wordItem
    }
    
    func toWordItem() -> WordItem {
        let wordItem = WordItem(
            id: id,
            recordName: recordName.isEmpty ? nil : recordName,
            word: word,
            mean: mean,
            lastModified: lastModified,
            additionalInfo: additionalInfo,
            tags: parseTags(tags),
            difficulty: WordItem.WordDifficulty.parse(int: difficulty),
            status: WordItem.WordStatus.parse(int: status))
        return wordItem
    }
}

extension RMWordItem {
    private func parseTags(_ tags: String) -> [TagItem] {
        let tagItems = tags.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ",")
            .map { String($0) }
            .map { TagItem(title: $0) }
        return tagItems
    }
    
    private func convertTagsToCSVFormatString(_ tags: [String]) -> String {
        var csvFormatString = tags
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .reduce("") { results, tag in
            return "\(results),\(tag)"
        }
        
        if csvFormatString.starts(with: ",") {
            csvFormatString = String(csvFormatString.dropFirst())
        }
        if csvFormatString.last == "," {
            csvFormatString = String(csvFormatString.dropLast())
        }
        
        return csvFormatString
    }
}
