//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

typealias URLItemResult = ((Result<URLItemType>) -> Void)
typealias SuccessResult = ((Result<Void>) -> Void)

protocol SyncingPersistenceType: class {
    
    var ids: Set<String> { get }    
    func sync(quickResult: SuccessResult?, fullResult: SuccessResult?)
    func createItem(withID: String?, quickResult: URLItemResult?, fullResult: URLItemResult?)
    func readItem(withID id: String, quickResult: URLItemResult?, fullResult: URLItemResult?)
    func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?)
    func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?)
}
