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
    func createItem(result: @escaping URLItemResult)
    func readItem(withID id: String, result: @escaping URLItemResult)
    func update(item: URLItemType)
    func delete(item: URLItemType)

    typealias URLItemResult = ((Result<URLItemType>) -> Void)
    typealias SuccessResult = ((Result<Void>) -> Void)?
}
