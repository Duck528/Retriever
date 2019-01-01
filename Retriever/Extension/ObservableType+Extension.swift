//
//  ObservableType+Extension.swift
//  Retriever
//
//  Created by thekan on 26/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import RxSwift
import RxCocoa
import Foundation

public protocol OptionalType {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

extension Optional: OptionalType {
    public var value: Wrapped? {
        return self
    }
}

extension ObservableType where E: OptionalType {
    public func filterOptional() -> Observable<E.Wrapped> {
        return self.flatMap { element -> Observable<E.Wrapped> in
            guard let value = element.value else {
                return Observable<E.Wrapped>.empty()
            }
            return Observable<E.Wrapped>.just(value)
        }
    }
}

extension SharedSequenceConvertibleType where E: OptionalType {
    public func filterOptional() -> Driver<E.Wrapped> {
        return self.flatMap { element -> Driver<E.Wrapped> in
            guard let value = element.value else {
                return Driver<E.Wrapped>.empty()
            }
            return Driver<E.Wrapped>.just(value)
        }
    }
}

extension ObservableType where E: Equatable {
    // 값이 다르거나, 값이 같아도 시간이 time보다 많이 지난 후라면 emit한다.
    func distinctUntilChanged(orTimepass time: RxTimeInterval) -> Observable<E> {
        return self
            .map { ($0, Date()) }
            .distinctUntilChanged {
                let (prevValue, prevDate) = $0
                let (currValue, currDate) = $1
                return (prevValue == currValue && currDate.timeIntervalSince(prevDate) < time)
            }.map { $0.0 }
    }
}
