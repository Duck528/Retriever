//
//  FetchTagUsecase.swift
//  Retriever
//
//  Created by thekan on 24/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RxSwift

class FetchTagUsecase {
    func execute() -> Observable<[TagItem]> {
        let tagItem = [
            TagItem(title: "Tag01"),
            TagItem(title: "Tag02"),
            TagItem(title: "Tag03"),
            TagItem(title: "Tag04"),
            TagItem(title: "Tag05"),
            TagItem(title: "Tag06"),
            TagItem(title: "Tag07"),
            TagItem(title: "Tag08")
        ]
        return .of(tagItem)
    }
}
