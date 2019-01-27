//
//  UpdateLatestSyncTimeUsecase.swift
//  Retriever
//
//  Created by thekan on 05/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import Foundation
import RxSwift

class UpdateLatestSyncTimeUsecase {
    let latestSyncTimeKey = "LatestTime"
    
    func execute(date: Date = Date()) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            UserDefaults.standard.set(date, forKey: self.latestSyncTimeKey)
            return .just(())
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
        
    }
}
