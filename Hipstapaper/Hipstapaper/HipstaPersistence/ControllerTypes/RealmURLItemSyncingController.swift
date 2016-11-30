//
//  RealmSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class RealmURLItemSyncingController: NSObject, SyncingPersistenceType { //NSObject for KVO compliance
    
    private(set) var ids: Set<String> = []
    
    private let serialQueue = DispatchQueue(label: "RealmURLItemSyncingController", qos: .userInitiated)

    func sync(quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let ids = RealmURLItemSyncingController.allRealmObjectIDs(from: realm)
                self.ids = ids
                quickResult(.success())
                fullResult(.success())
            } catch {
                NSLog("realmSyncError: \(error)")
                self.ids = []
                quickResult(.error([error]))
                fullResult(.error([error]))
            }
        }
    }
    
    func createItem(withID id: String?, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.serialQueue.async {
            do {
                let newObject = URLItemRealmObject()
                if let id = id {
                    newObject.realmID = id
                }
                let realm = try Realm()
                realm.beginWrite()
                realm.add(newObject)
                try realm.commitWrite()
                let value = URLItem.Value(realmObject: newObject)
                quickResult(.success(value))
                fullResult(.success(value))
            } catch {
                NSLog("createURLItemError: \(error)")
                quickResult(.error([error]))
                fullResult(.error([error]))
            }
        }
    }
    
    func readItem(withID id: String, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: id, from: realm)
                    else { quickResult(.error([NSError()])); fullResult(.error([NSError()])); return; }
                let value = URLItem.Value(realmObject: realmObject)
                quickResult(.success(value))
                fullResult(.success(value))
            } catch {
                NSLog("readURLItemWithID: \(id), Error: \(error)")
                quickResult(.error([error]))
                fullResult(.error([error]))
            }
        }
    }
    
    func update(item: URLItemType, quickResult: @escaping URLItemResult, fullResult: @escaping URLItemResult) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
                    else { quickResult(.error([NSError()])); fullResult(.error([NSError()])); return; }
                realm.beginWrite()
                realmObject.cloudKitID = item.cloudKitID
                realmObject.urlString = item.urlString
                realmObject.archived = item.archived
                realmObject.tagList = type(of: self).loadTagListMatching(tagItemArray: item.tags, from: realm)
                realmObject.modificationDate = item.modificationDate
                try realm.commitWrite()
                let updatedValue = URLItem.Value(realmObject: realmObject)
                quickResult(.success(updatedValue))
                fullResult(.success(updatedValue))
            } catch {
                NSLog("updateURLItemError: \(error)")
                quickResult(.error([error]))
                fullResult(.error([error]))
            }
        }
    }
    
    func delete(item: URLItemType, quickResult: @escaping SuccessResult, fullResult: @escaping SuccessResult) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
                    else { quickResult(.error([NSError()])); fullResult(.error([NSError()])); return; }
                realm.beginWrite()
                realm.delete(realmObject)
                try realm.commitWrite()
                quickResult(.success(()))
                fullResult(.success(()))
            } catch {
                NSLog("readURLItemWithID: \(item.realmID), Error: \(error)")
                quickResult(.error([error]))
                fullResult(.error([error]))
            }
        }
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
    
    private class func realmObject(withID id: String, from realm: Realm) -> URLItemRealmObject? {
        return realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: id)
    }
    
    // MARK: Load and Set Tag List
    
    private class func loadTagListMatching(tagItemArray: [TagItemType], from realm: Realm) -> List<TagItemRealmObject> {
        let stringSet = Set(tagItemArray.map({ $0.name }))
        let realmObjects = stringSet.map() { nameString -> TagItemRealmObject? in
            if let existingObject = realm.object(ofType: TagItemRealmObject.self, forPrimaryKey: nameString) {
                return existingObject
            } else {
                return self.newTagObject(withName: nameString, from: realm)
            }
        }.filter({ $0 != nil }).map({ $0! })
        let list = List(realmObjects)
        return list
    }
    
    private class func newTagObject(withName name: String, from realm: Realm) -> TagItemRealmObject? {
        do {
            let newObject = TagItemRealmObject(name: name)
            realm.beginWrite()
            realm.add(newObject)
            try realm.commitWrite()
            return newObject
        } catch {
            NSLog("createTagItemError: \(error)")
            return .none
        }
    }
}







