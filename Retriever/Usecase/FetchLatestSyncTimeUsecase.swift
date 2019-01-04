//
//  FetchLatestSyncTimeUsecase.swift
//  Retriever
//
//  Created by thekan on 05/01/2019.
//  Copyright © 2019 thekan. All rights reserved.
//

import Foundation
import RxSwift

class FetchLatestSyncTimeUsecase {
    let latestSyncTimeKey = "LatestTime"
    
    func execute() -> Observable<Date?> {
        return Observable.deferred({ () -> Observable<Date?> in
            let latestTime = UserDefaults.standard.object(forKey: self.latestSyncTimeKey) as? Date
            return .just(latestTime)
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
}
