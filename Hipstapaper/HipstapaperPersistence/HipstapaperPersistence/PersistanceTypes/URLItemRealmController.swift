//
//  RealmSyncingController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

open class URLItemRealmController {
    
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

extension URLItemRealmController: URLItemCRUDSinglePersistanceType {

    public func allItems(sortedBy: URLItem.Sort, ascending: Bool, result: URLItemIDsResult?) {
        self.serialQueue.async {
            do {
                let realm = try Realm()
                let ids = URLItemRealmController.allRealmObjectIDs(from: realm, sortedBy: sortedBy, ascending: ascending)
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
    
    // MARK: Load All URLItem Objects from Disk
    
    private class func allRealmObjects(from realm: Realm, sortedBy: URLItem.Sort = .modificationDate, ascending: Bool = true) -> Results<URLItemRealmObject> {
        return realm.objects(URLItemRealmObject.self).sorted(byProperty: sortedBy.realmPropertyName, ascending: ascending)
    }
    
    private class func realmObjectIDs(from results: Results<URLItemRealmObject>) -> Set<String> {
        return Set(results.map({ $0.realmID }))
    }
    
    private class func allRealmObjectIDs(from realm: Realm, sortedBy: URLItem.Sort, ascending: Bool) -> Array<String> {
        let results = self.allRealmObjects(from: realm, sortedBy: sortedBy, ascending: ascending)
        let ids = results.map({ $0.realmID })
        return Array(ids)
    }
    
    // MARK: Load individual items
    
    private class func realmObject(withID id: String, from realm: Realm) -> URLItemRealmObject? {
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

extension URLItemRealmController: URLItemCRUDDoublePersistanceType {
    public func sync(sortedBy: URLItem.Sort, ascending: Bool, quickResult: URLItemIDsResult?, fullResult: URLItemIDsResult?) {
        self.allItems(sortedBy: sortedBy, ascending: ascending) { result in
            quickResult?(result)
            fullResult?(result)
        }
    }
    public func allItems(sortedBy: URLItem.Sort, ascending: Bool, quickResult: URLItemIDsResult?, fullResult: URLItemIDsResult?) {
        self.allItems(sortedBy: sortedBy, ascending: ascending) { result in
            quickResult?(result)
            fullResult?(result)
        }
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







