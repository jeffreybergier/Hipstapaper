//
//  SyncingPersistenceProtocol.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

public typealias URLItemIDsResult = ((Result<[String]>) -> Void)
public typealias URLItemResult = ((Result<URLItemType>) -> Void)
public typealias TagListResult = ((Result<[TagItemType]>) -> Void)
public typealias SuccessResult = ((Result<Void>) -> Void)

// This protocol is intended for use systems that use a local database (quick)
// and a cloud based persistence layer (full)
// It allows me to return the available results quickly
// But also keep the UI showing that network activity is happening

public protocol URLItemCRUDDoublePersistanceType: class {
    var isSyncing: Bool { get }
    func sync(result: SuccessResult?)
    func allItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?)
    func create(item: URLItemType?, quickResult: URLItemResult?, fullResult: URLItemResult?)
    func readItem(withID id: String, result: URLItemResult?)
    func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?)
    func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?)
}

// This protocol is intended for systems that use either a local database or a cloud storage system
public protocol URLItemCRUDSinglePersistanceType: class {
    func allItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?)
    func create(item: URLItemType?, result: URLItemResult?)
    func readItem(withID id: String, result: URLItemResult?)
    func update(item: URLItemType, result: URLItemResult?)
    func delete(item: URLItemType, result: SuccessResult?)
}

public protocol URLItemQueryPersistanceType: class {
    func tagItems(result: TagListResult?)
    func unarchivedItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?)
    func allItems(for tag: TagItemType, sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?)
}

public protocol URLItemDoublePersistanceType: URLItemCRUDDoublePersistanceType, URLItemQueryPersistanceType { }
public protocol URLItemSinglePersistanceType: URLItemCRUDSinglePersistanceType, URLItemQueryPersistanceType { }