//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

protocol SyncingPersistenceType: class {
    
    var ids: Set<String> { get }
    
    var isSyncing: Bool { get }
    func sync(completionHandler: SuccessResult)
    func createItem() -> URLItemType?
    func read(itemWithID id: String) -> URLItemType?
    func update(item: URLItemType)
    func delete(item: URLItemType)

//    func create(item: URLItemType, completionHandler: UUIDResult)
//    func read(itemWithID id: String, completionHandler: ItemResult)
//    func update(item: URLItemType, completionHandler: UUIDResult)
//    func delete(item: URLItemType, completionHandler: SuccessResult)
    
    typealias UUIDResults = (([Result<String>]) -> Void)?
    typealias UUIDResult = ((Result<String>) -> Void)?
    typealias ItemResult = ((Result<URLItemType>) -> Void)?
    typealias SuccessResult = ((Result<Void>) -> Void)?
}
