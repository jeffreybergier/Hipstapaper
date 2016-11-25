//
//  RealmManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

class URLRealmItemStorer: NSObject {
    
    private(set) var realmItemIDs = Set<String>()
    private var notificationToken: NotificationToken?
    
    override init() {
        let realm = try! Realm()
        self.realmItemIDs = URLRealmItemStorer.allRealmObjectIDs(from: realm)
        super.init()
        self.notificationToken = realm.addNotificationBlock() { (_, realm) in
            let realm = try! Realm()
            self.realmItemIDs = URLRealmItemStorer.allRealmObjectIDs(from: realm)
        }
    }
    
    func sync() {
        let syncer = CloudKitSyncer()
        syncer.allCloudKitURLItems() { result in
            switch result {
            case .error(let error):
                NSLog("Error While Syncing from CloudKit: \(error)")
            case .success(let cloudObjects):
                let realm = try! Realm()
                let realmObjects = type(of: self).allRealmObjects(from: realm)
                let comparison = CloudKitRealmComparator(realm: realmObjects, cloud: cloudObjects)
                
                let realmItemsToAddToCloud = comparison.addToCloud?.map() { realmID -> URLItem.Value in
                    let item = type(of: self).realmObject(withID: realmID)
                    return URLItem.Value(realmID: item.realmID, cloudKitID: item.cloudKitID, urlString: item.urlString, archived: item.archived, tags: Array(item.tagList), modificationDate: item.modificationDate)
                }
                if let realmItemsToAddToCloud = realmItemsToAddToCloud {
                    NSLog("Syncing: New Realm Items to Create in CloudKit: \(realmItemsToAddToCloud.count)")
                    self.addNewItemsToCloudKit(items: realmItemsToAddToCloud)
                }
                
                let realmItemsToUpdateInCloud = comparison.updateInCloud?.map() { (realmID, cloudKitObject) -> (URLItem.Value, URLItem.CloudKitObject) in
                    let item = type(of: self).realmObject(withID: realmID)
                    let value = URLItem.Value(realmID: item.realmID, cloudKitID: item.cloudKitID, urlString: item.urlString, archived: item.archived, tags: Array(item.tagList), modificationDate: item.modificationDate)
                    return (value, cloudKitObject)
                }
                
                if let realmItemsToUpdateInCloud = realmItemsToUpdateInCloud {
                    NSLog("Syncing: Items Changed Locally to Upload: \(realmItemsToUpdateInCloud.count)")
                    self.updateItemsInCloudKit(items: realmItemsToUpdateInCloud)
                }
                
                if let cloudItemsToUpdateInRealm = comparison.addOrUpdateInRealm {
                    NSLog("Syncing: Items Changed in Cloud to Sync Locally: \(cloudItemsToUpdateInRealm.count)")
                    self.updateItemsInRealm(items: cloudItemsToUpdateInRealm)
                }
            }
        }
    }
    
    private func addNewItemsToCloudKit(items: [URLItemType]) {
        let adder = CloudKitSyncer()
        let newRecords = items.map({ ($0.realmID, URLItem.CloudKitObject(urlItem: $0).record) })
        adder.save(records: newRecords) { dictionary in
            for (realmID, cloudKitResult) in dictionary {
                switch cloudKitResult {
                case .success(let cloudKitID):
                    type(of: self).updateRealmObject(withID: realmID) { object in
                        object.cloudKitID = cloudKitID
                    }
                case .error(let error):
                    NSLog("Error saving realmID: \(realmID) to CloudKit: \(error)")
                }
            }
        }
    }
    
    private func updateItemsInCloudKit(items: [(URLItem.Value, URLItem.CloudKitObject)]) {
        for (realm, cloud) in items {
            cloud.archived = realm.archived
            cloud.urlString = realm.urlString
            cloud.tags = Set(realm.tags.map({ $0.name }))
        }
        let records = items.map({ ($0.0.realmID, $0.1.record) })
        let updater = CloudKitSyncer()
        updater.save(records: records) { dictionary in
            for (realmID, cloudKitResult) in dictionary {
                switch cloudKitResult {
                case .success:
                    break
                case .error(let error):
                    NSLog("Error saving realmID: \(realmID) to CloudKit: \(error)")
                }
            }
        }
    }
    
    private func updateItemsInRealm(items: [(realmID: String?, cloudKitObject: URLItem.CloudKitObject)]) {
        let realm = try! Realm()
        realm.beginWrite()
        for (realmID, cloudKitObject) in items {
            let realmObject: URLItemRealmObject
            if let realmID = realmID {
                realmObject = type(of: self).realmObject(withID: realmID, from: realm)
            } else {
                realmObject = URLItemRealmObject()
                realm.add(realmObject)
            }
            realmObject.cloudKitID = cloudKitObject.cloudKitID
            realmObject.urlString = cloudKitObject.urlString
            realmObject.archived = cloudKitObject.archived
            let newOrExistingTags = cloudKitObject.tags.map() { tagName -> TagItemRealmObject in
                return realm.object(ofType: TagItemRealmObject.self, forPrimaryKey: tagName) ?? TagItemRealmObject(name: tagName)
            }
            realmObject.tagList = List<TagItemRealmObject>(newOrExistingTags)
        }
        try! realm.commitWrite()
    }
    
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
    
    private class func realmAndRealmObject(withID id: String) -> (object: URLItemRealmObject, realm: Realm) {
        let realm = try! Realm()
        let realmObject = self.realmObject(withID: id, from: realm)
        return (realmObject, realm)
    }
    
    private class func realmObject(withID id: String, from realm: Realm) -> URLItemRealmObject {
        return realm.object(ofType: URLItemRealmObject.self, forPrimaryKey: id)!
    }
    
    class func realmObject(withID id: String) -> URLItemRealmObject {
        return self.realmAndRealmObject(withID: id).object
    }
    
    class func updateRealmObjects(withIDs ids: [String], updates: ([URLItemRealmObject]) -> Void) {
        let realm = try! Realm()
        realm.beginWrite()
        let objects = ids.map({ self.realmObject(withID: $0, from: realm) })
        updates(objects)
        try! realm.commitWrite()
    }
    
    class func updateRealmObject(withID id: String, updates: (URLItemRealmObject) -> Void) {
        let (object, realm) = self.realmAndRealmObject(withID: id)
        realm.beginWrite()
        updates(object)
        object.modificationDate = Date()
        try! realm.commitWrite()
    }
    
    class func idForNewRealmObject() -> String {
        let realm = try! Realm()
        let realmObject = URLItemRealmObject()
        realm.beginWrite()
        realm.add(realmObject)
        try! realm.commitWrite()
        return realmObject.realmID
    }
}

