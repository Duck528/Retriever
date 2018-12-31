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
    func resolve() -> SaveWordUsecase {
        let repository = WordICloudRepository()
        return SaveWordUsecase(repository)
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
}
