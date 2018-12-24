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
            TagItem(title: "Tag1"),
            TagItem(title: "Tag2"),
            TagItem(title: "Tag3"),
            TagItem(title: "Tag4"),
            TagItem(title: "Tag5"),
            TagItem(title: "Tag6"),
            TagItem(title: "Tag7"),
            TagItem(title: "Tag8")
        ]
        return .of(tagItem)
    }
}
