//
//  IocContainer.swift
//  Retriever
//
//  Created by thekan on 23/12/2018.
//  Copyright © 2018 thekan. All rights reserved.
//

import Foundation

class Assembler: AssemblerProtocol { }

protocol ViewModelAssembler { }
protocol UsecaseAssembler { }

protocol AssemblerProtocol: ViewModelAssembler, UsecaseAssembler { }

extension ViewModelAssembler where Self: Assembler {
    func resolve() -> RootViewModel {
        return RootViewModel()
    }
    
    func resolve() -> HomeViewModel {
        return HomeViewModel()
    }
}

extension UsecaseAssembler where Self: Assembler {
    func resolve() -> SaveRemoteWordUsecase {
        let repository = WordICloudRepository()
        return SaveRemoteWordUsecase(repository)
    }
    
    func resolve() -> SaveLocalWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return SaveLocalWordUsecase(wordItemDAO: wordItemDAO)
    }
    
    func resolve() -> FetchRemoteWordUsecase {
        let repository = WordICloudRepository()
        return FetchRemoteWordUsecase(repository)
    }
    
    func resolve() -> FetchLocalWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return FetchLocalWordUsecase(wordDAO: wordItemDAO)
    }
    
    func resolve() -> SyncDatabaseUsecase {
        let wordRepository = WordICloudRepository()
        let wordItemDAO = RMWordItemDAO()
        return SyncDatabaseUsecase(wordRepository: wordRepository, wordDAO: wordItemDAO)
    }
    
    func resolve() -> UpdateLocalWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return UpdateLocalWordUsecase(wordDAO: wordItemDAO)
    }
    
    func resolve() -> DeleteLocalWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return DeleteLocalWordUsecase(wordItemDAO: wordItemDAO)
    }
    
    func resolve() -> FetchNumberOfUpdatedWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return FetchNumberOfUpdatedWordUsecase(wordItemDAO: wordItemDAO)
    }
    
    func resolve() -> FetchNumberOfDeletedWordUsecase {
        let wordItemDAO = RMWordItemDAO()
        return FetchNumberOfDeletedWordUsecase(wordItemDAO: wordItemDAO)
    }
}
