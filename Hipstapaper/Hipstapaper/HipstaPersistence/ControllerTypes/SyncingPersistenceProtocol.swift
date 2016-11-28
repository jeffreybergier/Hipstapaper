//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

protocol SyncingPersistenceType: class {
    
    var ids: Set<String> { get }    
    func sync(result: @escaping SuccessResult)
    func createItem(result: @escaping URLItemResult)
    func readItem(withID id: String, result: @escaping URLItemResult)
    func update(item: URLItemType, result: @escaping URLItemResult)
    func delete(item: URLItemType, result: @escaping SuccessResult)
    
    typealias URLItemResult = ((Result<URLItemType>) -> Void)
    typealias SuccessResult = ((Result<Void>) -> Void)
}
