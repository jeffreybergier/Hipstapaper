//
//  RealmSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class RealmURLItemSyncingController: SyncingPersistenceType {
    
    var ids: Set<String>
    var isSyncing = false
    
    init() {
        let realm = try! Realm()
        let ids = RealmURLItemSyncingController.allRealmObjectIDs(from: realm)
        self.ids = ids
    }

    func sync(completionHandler: (([Result<String>]) -> Void)?) {
        
    }
    
    func create(item: URLItemType, completionHandler: SyncingPersistenceType.UUIDResult) {
        
    }
    
    func read(itemWithID id: String) -> URLItemType {
        let realm = try! Realm()
        let realmObject = type(of: self).realmObject(withID: id, from: realm)
        let value = URLItem.Value(realmObject: realmObject)
        return value
    }
    
    func read(itemWithID id: String, completionHandler: SyncingPersistenceType.ItemResult) {
        
    }
    
    func update(item: URLItemType, completionHandler: SyncingPersistenceType.UUIDResult) {
        
    }
    
    func delete(item: URLItemType, completionHandler: SyncingPersistenceType.SuccessResult) {
        
    }

    
    // MARK: Load All URLItem Objects from Disk
    
    private class func allRealmObjects(from realm: Realm) -> Results<URLItemRealmObject> {
        return realm.objects(URLItemRealmObject.self)
    }
    
    private class func realmObjectIDs(from results: Results<URLItemRealmObject>) -> Set<String> {
        return Set(results.map({ $0.realmID }))
    }
    
    private class func allRealmObjectIDs(from realm: Realm) -> Set<String> {
        let results = self.allRealmObjects(from: realm)
        let ids = self.realmObjectIDs(from: results)
        return ids
    }
    
    // MARK: Load individual items
    
    private class func realmObject(withID id: String, from realm: Realm) -> URLItemRealmObject {
        return realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: id)!
    }
}
