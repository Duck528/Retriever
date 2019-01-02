//
//  RMConfiguration.swift
//  Retriever
//
//  Created by thekan on 31/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

enum DBErrors: Error {
    case duplicatedPrimaryKey
    case notFounded
}

protocol BaseDAO {
    associatedtype ModelType: Object, Storable
}

extension BaseDAO {
    func count() -> Observable<Int> {
        return Observable.deferred({ () -> Observable<Int> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let count = realm.objects(ModelType.self).count
                return .just(count)
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    // 확인이 필요 함
    func insert(_ modelArray: [ModelType]) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                if !Set(realm.objects(ModelType.self)).intersection(Set(modelArray)).isEmpty {
                    throw DBErrors.duplicatedPrimaryKey
                }
                try realm.write {
                    realm.add(modelArray, update: false)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func insert(_ model: ModelType) -> Observable<ModelType.ConvertType> {
        return Observable.deferred({ () -> Observable<ModelType.ConvertType> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                if realm.object(ofType: ModelType.self, forPrimaryKey: model.primaryKey) != nil {
                    throw DBErrors.duplicatedPrimaryKey
                }
                try realm.write {
                    realm.add(model, update: false)
                }
            } catch {
                return .error(error)
            }
            return Observable.just(model.convert())
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func find(by key: ModelType.PrimaryKeyType) -> Observable<ModelType.ConvertType?> {
        return Observable.deferred({ () -> Observable<ModelType.ConvertType?> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let finded = realm.object(ofType: ModelType.self, forPrimaryKey: key)
                    .map { $0.convert() }
                return .just(finded)
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func findAll() -> Observable<[ModelType.ConvertType]> {
        return Observable.deferred({ () -> Observable<[ModelType.ConvertType]> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let finded = realm.objects(ModelType.self)
                    .map { $0.convert() }
                return .just(Array(finded))
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func finds(filter: @escaping ((ModelType) -> Bool)) -> Observable<[ModelType.ConvertType]> {
        return Observable.deferred({ () -> Observable<[ModelType.ConvertType]> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let filteredModels = realm.objects(ModelType.self)
                    .filter { filter($0) }
                    .map { $0.convert() }
                return .just(Array(filteredModels))
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func delete(by key: ModelType.PrimaryKeyType) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                if let finded = realm.object(ofType: ModelType.self, forPrimaryKey: key) {
                    try realm.write {
                        realm.delete(finded)
                    }
                } else {
                    throw DBErrors.notFounded
                }
            } catch {
                return .error(error)
            }
            return .just(())
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func deleteAll() -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                try realm.write {
                    realm.deleteAll()
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func deletes(filter: @escaping ((ModelType) -> Bool)) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                let findedModels = realm.objects(ModelType.self)
                    .filter { filter($0) }
                try realm.write {
                    realm.delete(findedModels)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func update(_ model: ModelType) -> Observable<ModelType.ConvertType> {
        return Observable.deferred({ () -> Observable<ModelType.ConvertType> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                if realm.object(ofType: ModelType.self, forPrimaryKey: model.primaryKey) != nil {
                    try realm.write {
                        realm.create(ModelType.self, value: model, update: true)
                    }
                } else {
                    throw DBErrors.notFounded
                }
                return .just(model.convert())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func updates(array: [ModelType]) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                try realm.write {
                    for model in array {
                        realm.create(ModelType.self, value: model, update: true)
                    }
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func updateOrCreate(model: ModelType) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                try realm.write {
                    realm.create(ModelType.self, value: model, update: true)
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    func updateOrCreate(array: [ModelType]) -> Observable<Void> {
        return Observable.deferred({ () -> Observable<Void> in
            do {
                let realm = try Realm(configuration: RMConfiguration.realmConfig)
                try realm.write {
                    for model in array {
                        realm.create(ModelType.self, value: model, update: true)
                    }
                }
                return .just(())
            } catch {
                return .error(error)
            }
        }).subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
}

