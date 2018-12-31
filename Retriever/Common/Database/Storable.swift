//
//  Storable.swift
//  article
//
//  Created by 안덕환 on 2018. 7. 18..
//  Copyright © 2018년 Naver. All rights reserved.
//

import Foundation

protocol Storable {
    associatedtype PrimaryKeyType
    associatedtype ConvertType
    
    var primaryKey: PrimaryKeyType { get }
    func convert() -> ConvertType
}
