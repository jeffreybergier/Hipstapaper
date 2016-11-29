//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

typealias URLItemResults = (([Result<URLItemType>]) -> Void)
typealias URLItemResult = ((Result<URLItemType>) -> Void)
typealias SuccessResult = ((Result<Void>) -> Void)

protocol SyncingPersistenceType: class {
    
    var ids: Set<String> { get }    
    func sync(quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult)
    func createItem(withID: String?, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult)
    func readItem(withID id: String, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult)
    func update(item: URLItemType, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult)
    func delete(item: URLItemType, quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult)
}
