//
//  RealmSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

open class URLItemRealmController: URLItemSinglePersistanceType {
    
    #if os(OSX)
    private static let appGroupIdentifier = "V6ESYGU6CV.hipstapaper.appgroup"
    #else
    private static let appGroupIdentifier = "group.com.saturdayapps.Hipstapaper"
    #endif
    
    // Void Singleton to configure the default realm for the app once
    // this enables realm to use the app group for storage
    // also opens up the possibility to setting an encryption key
    private static let configureRealmDirectory: Void = {
        let directory = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: URLItemRealmController.appGroupIdentifier
            )!
        let realmPath = directory.appendingPathComponent("db.realm")
        var config = Realm.Configuration.defaultConfiguration
        config.deleteRealmIfMigrationNeeded = true // this can be true because the cloud is the source of truth
        config.fileURL = realmPath
        Realm.Configuration.defaultConfiguration = config
    }()
    
    fileprivate let serialQueue = DispatchQueue(label: "RealmURLItemSyncingController", qos: .userInitiated)
    
    public init() {
        // call the singleton to configure it
        URLItemRealmController.configureRealmDirectory
    }
}

extension URLItemRealmController: URLItemQueryPersistanceType {
    public func tagItems(result: TagListResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let realmItems = type(of: self).allTagItems(from: realm)
                let items = realmItems.map({ TagItem.Value(name: $0.name, itemCount: $0.items.count) })
                result?(.success(Array(items)))
            } catch {
                NSLog("realmSyncError: \(error)")
                result?(.error([error]))
            }
        }
    }
    public func unarchivedItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let ids = type(of: self).unarchivedRealmObjectIDs(from: realm, sortedBy: sortedBy, ascending: ascending)
                result?(.success(ids))
            } catch {
                NSLog("realmSyncError: \(error)")
                result?(.error([error]))
            }
        }
    }
    public func allItems(for tag: TagItemType, sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let urlItemIDs = type(of: self).urlItemsIDs(for: tag, from: realm, sortedBy: sortedBy, ascending: ascending)
                result?(.success(urlItemIDs))
            } catch {
                NSLog("realmSyncError: \(error)")
                result?(.error([error]))
            }
        }
    }
}

extension URLItemRealmController: URLItemCRUDSinglePersistanceType {

    public func allItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let ids = type(of: self).allRealmObjectIDs(from: realm, sortedBy: sortedBy, ascending: ascending)
                result?(.success(ids))
            } catch {
                NSLog("realmSyncError: \(error)")
                result?(.error([error]))
            }
        }
    }
    
    public func create(item: URLItemType?, result: URLItemResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let newObject: URLItemRealmObject
                if let item = item {
                    newObject = URLItemRealmObject(urlItem: item, realm: realm)
                } else {
                    newObject = URLItemRealmObject()
                }
                realm.beginWrite()
                realm.add(newObject)
                newObject.tagList = type(of: self).loadTagListMatching(tagItemArray: ["FakeTag1", "FakeTag2", "FakeTag3"], from: realm)
                try realm.commitWrite()
                let value = URLItem.Value(realmObject: newObject)
                result?(.success(value))
            } catch {
                NSLog("createURLItemError: \(error)")
                result?(.error([error]))
            }
        }    }
    
    public func readItem(withID id: String, result: URLItemResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: id, from: realm)
                    else { result?(.error([NSError()])); return; }
                let value = URLItem.Value(realmObject: realmObject)
                result?(.success(value))
            } catch {
                NSLog("readURLItemWithID: \(id), Error: \(error)")
                result?(.error([error]))
            }
        }
    }
    
    public func update(item: URLItemType, result: URLItemResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
                    else { result?(.error([NSError()])); return; }
                realm.beginWrite()
                realmObject.cloudKitID = item.cloudKitID
                realmObject.urlString = item.urlString
                realmObject.archived = item.archived
                realmObject.tagList = type(of: self).loadTagListMatching(tagItemArray: item.tags, from: realm)
                realmObject.modificationDate = item.modificationDate
                try realm.commitWrite()
                let updatedValue = URLItem.Value(realmObject: realmObject)
                result?(.success(updatedValue))
            } catch {
                NSLog("updateURLItemError: \(error)")
                result?(.error([error]))
            }
        }
    }
    
    public func delete(item: URLItemType, result: SuccessResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                guard let realmObject = type(of: self).realmObject(withID: item.realmID, from: realm)
                    else { result?(.error([NSError()])); return; }
                realm.beginWrite()
                realm.delete(realmObject)
                try realm.commitWrite()
                result?(.success(()))
            } catch {
                NSLog("readURLItemWithID: \(item.realmID), Error: \(error)")
                result?(.error([error]))
            }
        }
    }
}

extension URLItemRealmController {

    // MARK: Load All URLItem Objects from Disk
    
    fileprivate class func allRealmObjectIDs(from realm: Realm, sortedBy: URLItem.Sort, ascending: Bool) -> Array<String> {
        let results = realm.objects(URLItemRealmObject.self).sorted(byProperty: sortedBy.realmPropertyName, ascending: ascending)
        let ids = results.map({ $0.realmID })
        return Array(ids)
    }
    
    fileprivate class func unarchivedRealmObjectIDs(from realm: Realm, sortedBy: URLItem.Sort, ascending: Bool) -> Array<String> {
        let results = realm.objects(URLItemRealmObject.self).filter("archived = NO").sorted(byProperty: sortedBy.realmPropertyName, ascending: ascending)
        let ids = results.map({ $0.realmID })
        return Array(ids)
    }
    
    fileprivate class func urlItemsIDs(for tag: TagItemType, from realm: Realm, sortedBy: URLItem.Sort, ascending: Bool) -> Array<String> {
        guard let tag = realm.object(ofType: TagItemRealmObject.self, forPrimaryKey: tag.name) else { return [] }
        let urlItems = tag.items.sorted(byProperty: sortedBy.realmPropertyName, ascending: ascending)
        let urlItemIDs = urlItems.map({ $0.realmID })
        return Array(urlItemIDs)
    }
    
    fileprivate class func allTagItems(from realm: Realm) -> Results<TagItemRealmObject> {
//        let results = realm.objects(TagItemRealmObject.self).filter("items.count > 0").sorted(byProperty: "name", ascending: true)
        let results = realm.objects(TagItemRealmObject.self).sorted(byProperty: "name", ascending: true)
        return results
    }
    
    // MARK: Load individual items
    
    fileprivate class func realmObject(withID id: String, from realm: Realm) -> URLItemRealmObject? {
        return realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: id)
    }
    
    // MARK: Load and Set Tag List
    
    internal class func loadTagListMatching(tagItemArray: [TagItemType], from realm: Realm) -> List<TagItemRealmObject> {
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
    
    fileprivate class func newTagObject(withName name: String, from realm: Realm) -> TagItemRealmObject? {
        do {
            let newObject = TagItemRealmObject(name: name)
            let wasAlreadyWriting = realm.isInWriteTransaction
            if wasAlreadyWriting == false {
                realm.beginWrite()
            }
            realm.add(newObject)
            if wasAlreadyWriting == false {
                try realm.commitWrite()
            }
            return newObject
        } catch {
            NSLog("createTagItemError: \(error)")
            return .none
        }
    }
}

extension URLItemRealmController: URLItemDoublePersistanceType {
    public func sync(result: SuccessResult?) {
        result?(.success())
    }
    public func create(item: URLItemType?, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.create(item: item) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func update(item: URLItemType, quickResult: URLItemResult?, fullResult: URLItemResult?) {
        self.update(item: item) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func delete(item: URLItemType, quickResult: SuccessResult?, fullResult: SuccessResult?) {
        self.delete(item: item) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
}







