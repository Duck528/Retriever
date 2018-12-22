//
//  HomeViewModel.swift
//  Retriever
//
//  Created by thekan on 22/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift
import RxCocoa

class HomeViewModel {
    enum SyncState {
        case success
        case fail
        case unregistered
        case progress(ratio: CGFloat)
    }
    
    let synchronizedToRemote = BehaviorRelay<SyncState>(value: .unregistered)
}
