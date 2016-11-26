//
//  RealmSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class RealmURLItemSyncingController: SyncingPersistenceType {
    
    var ids: Set<String> = []
    var isSyncing = false

    func sync(completionHandler: SyncingPersistenceType.UUIDResults) {
        let realm = try! Realm()
        let ids = RealmURLItemSyncingController.allRealmObjectIDs(from: realm)
        self.ids = ids
        completionHandler?([])
    }
    
    func createItem() -> URLItemType {
        let newObject = URLItemRealmObject()
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(newObject)
        try! realm.commitWrite()
        let value = URLItem.Value(realmObject: newObject)
        return value
    }
    
    func read(itemWithID id: String) -> URLItemType {
        let realm = try! Realm()
        let realmObject = type(of: self).realmObject(withID: id, from: realm)
        let value = URLItem.Value(realmObject: realmObject)
        return value
    }
    
    func update(item: URLItemType) {
        let realm = try! Realm()
        let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
        realm.beginWrite()
        realmObject.cloudKitID = item.cloudKitID
        realmObject.urlString = item.urlString
        realmObject.archived = item.archived
        //realmObject.tags = item.tags
        realmObject.modificationDate = item.modificationDate
        try! realm.commitWrite()
    }
    
    func delete(item: URLItemType) {
        let realm = try! Realm()
        let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
        realm.beginWrite()
        realm.delete(realmObject)
        try! realm.commitWrite()
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
