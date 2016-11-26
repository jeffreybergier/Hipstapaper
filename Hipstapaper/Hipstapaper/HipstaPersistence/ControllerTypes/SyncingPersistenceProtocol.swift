//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

protocol SyncingPersistenceType {
    
    var ids: Set<String> { get }
    
    var isSyncing: Bool { get }
    func sync(completionHandler: (([Result<String>]) -> Void)?)
    
    func create(item: URLItemType, completionHandler: UUIDResult)
    func read(itemWithID id: String) -> URLItemType
    func read(itemWithID id: String, completionHandler: ItemResult)
    func update(item: URLItemType, completionHandler: UUIDResult)
    func delete(item: URLItemType, completionHandler: SuccessResult)
    
    typealias UUIDResult = ((Result<String>) -> Void)?
    typealias ItemResult = ((Result<URLItemType>) -> Void)?
    typealias SuccessResult = ((Result<Void>) -> Void)?
}
