//
//  RMConfiguration.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RealmSwift

class RMConfiguration {
    // 데이터베이스 스키마가 변경될 경우 마이그레이션을 위해 아래 schemaVersion을 하나씩 올려준다
    static var realmConfig = Realm.Configuration(
        schemaVersion: 3,
        migrationBlock: { _, oldSchemaVersion in
            switch oldSchemaVersion {
            default:
                break
            }
    })
}
